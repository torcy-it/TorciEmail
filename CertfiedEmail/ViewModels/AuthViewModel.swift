//
//  AuthViewModel.swift
//  CertfiedEmail
//
//  ViewModel di autenticazione e gestione sessione JWT.
//  Coordina login/logout, refresh utente e stato di sessione scaduta.
//

import SwiftUI
import Combine
import LocalAuthentication

@MainActor
final class AuthViewModel: ObservableObject {
    static let shared = AuthViewModel()
    
    // MARK: - Published Properties
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var showSessionExpired: Bool = false
    @Published var userEmail: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var canUseBiometrics: Bool = false
    @Published var biometricsEnabled: Bool = false
    @Published var biometricButtonTitle: String = "Use Face ID"
    @Published var showEnableBiometricsPrompt: Bool = false
    @Published var remainingLockoutSeconds: Int = 0
    @Published private(set) var hasStoredSession: Bool = false
    
    // MARK: - Dependencies
    private let repository: AuthRepository
    private let sessionService: SessionExpirationService
    
    private var cancellables = Set<AnyCancellable>()
    private var tokenExpirationTimer: Timer?
    private var lockoutTimer: Timer?
    private var failedLoginAttempts = 0
    private var lockoutUntil: Date?
    
    private let biometricsEnabledKey = "com.torciemail.biometrics.enabled"
    private let lastLoginEmailKey = "com.torciemail.lastLogin.email"
    
    // MARK: - Init
    
    /// Dependency Injection: il ViewModel dipende da protocollo repository
    /// e da un servizio dedicato all'osservazione della scadenza sessione.
    init(
        repository: AuthRepository = AuthRepositoryImpl(),
        sessionService: SessionExpirationService = DefaultSessionExpirationService()
    ) {
        self.repository = repository
        self.sessionService = sessionService
        self.biometricsEnabled = UserDefaults.standard.bool(forKey: biometricsEnabledKey)
        self.userEmail = UserDefaults.standard.string(forKey: lastLoginEmailKey) ?? ""
        
        configureBiometricAvailability()
        checkAuthStatus()
        observeSessionExpiration()
    }
    
    // MARK: - Auth Status
    
    /// Inizializza lo stato autenticazione dall'archivio locale e avvia i flussi correlati.
    private func checkAuthStatus() {
        let hasValidStoredSession = repository.isAuthenticated()
        hasStoredSession = hasValidStoredSession
        isAuthenticated = hasValidStoredSession
        
        if !isAuthenticated && sessionService.isAuthenticated {
            cleanupAuth()
        } else if isAuthenticated {
            // Se l'utente ha attivato biometria, richiedi sblocco all'avvio.
            if biometricsEnabled && canUseBiometrics {
                isAuthenticated = false
                return
            }

            Task { await refreshUserInfo() }
            startTokenExpirationMonitoring()
        }
    }
    
    // MARK: - Session Expiration Observer
    
    /// Osserva la scadenza sessione pubblicata dal service dedicato.
    private func observeSessionExpiration() {
        sessionService.sessionExpiredPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] expired in
                guard expired else { return }
                self?.handleSessionExpired()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Token Expiration Monitoring
    
    /// Avvia un timer periodico per verificare la scadenza del token JWT.
    private func startTokenExpirationMonitoring() {
        stopTokenExpirationMonitoring()
        
        guard let expirationDate = repository.getTokenExpirationDate() else {
            return
        }
        
        let now = Date()
        let timeUntilExpiration = expirationDate.timeIntervalSince(now)
        
        if timeUntilExpiration <= 0 {
            handleSessionExpired()
            return
        }
        
        // Check every 30 seconds
        tokenExpirationTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkTokenExpiration()
            }
        }
    }
    
    /// Ferma il monitoraggio periodico della scadenza token.
    private func stopTokenExpirationMonitoring() {
        tokenExpirationTimer?.invalidate()
        tokenExpirationTimer = nil
    }
    
    /// Verifica se il token e scaduto e innesca il flusso di scadenza.
    private func checkTokenExpiration() {
        if repository.isTokenExpired() {
            stopTokenExpirationMonitoring()
            handleSessionExpired()
        }
    }
    
    // MARK: - Refresh User Info
    
    /// Recupera i dati utente correnti dal server se il token e valido.
    private func refreshUserInfo() async {
        if self.userEmail.isEmpty && !repository.isTokenExpired() {
            do {
                let email = try await repository.getCurrentUser()
                self.userEmail = email
            } catch {
                errorMessage = "Unable to retrieve user data"
            }
        }
    }
    
    // MARK: - Login
    
    func login() async {
        if isLoginLocked {
            errorMessage = "Too many attempts. Try again in \(remainingLockoutSeconds)s."
            return
        }
        
        let normalizedEmail = userEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let validationError = validateLoginInput(email: normalizedEmail, password: normalizedPassword) else {
            errorMessage = nil
            isLoading = true
            userEmail = normalizedEmail
            
            do {
                _ = try await repository.login(username: normalizedEmail, password: password)
                isAuthenticated = true
                hasStoredSession = true
                failedLoginAttempts = 0
                errorMessage = nil
                UserDefaults.standard.set(normalizedEmail, forKey: lastLoginEmailKey)
                
                if canUseBiometrics && !biometricsEnabled {
                    showEnableBiometricsPrompt = true
                }
                
                startTokenExpirationMonitoring()
                await refreshUserInfo()
            } catch let error as RepositoryError {
                registerFailedLoginAttempt()
                errorMessage = error.errorDescription
            } catch {
                registerFailedLoginAttempt()
                errorMessage = "Unknown error"
            }
            
            isLoading = false
            return
        }
        
        errorMessage = validationError
    }
    
    /// Sblocca la sessione esistente richiedendo Face ID / Touch ID.
    func unlockWithBiometrics() async {
        guard canUseBiometrics else {
            errorMessage = "Biometrics are not available on this device."
            return
        }
        
        guard biometricsEnabled else {
            errorMessage = "Enable biometrics after logging in first."
            return
        }
        
        guard hasStoredSession else {
            errorMessage = "Please log in manually first."
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let unlocked = try await evaluateBiometricPolicy(
                reason: "Securely unlock CertfiedEmail"
            )
            guard unlocked else {
                errorMessage = "Biometric authentication was canceled."
                return
            }
            
            isAuthenticated = true
            errorMessage = nil
            startTokenExpirationMonitoring()
            await refreshUserInfo()
        } catch {
            errorMessage = "Unable to verify biometrics."
        }
    }
    
    /// Richiede consenso utente e abilita biometria locale.
    func enableBiometrics() async {
        guard canUseBiometrics else {
            errorMessage = "Biometrics are not available on this device."
            showEnableBiometricsPrompt = false
            return
        }
        
        do {
            let confirmed = try await evaluateBiometricPolicy(
                reason: "Enable Face ID/Touch ID for future sign-ins"
            )
            if confirmed {
                biometricsEnabled = true
                UserDefaults.standard.set(true, forKey: biometricsEnabledKey)
            }
        } catch {
            errorMessage = "Unable to enable biometrics."
        }
        
        showEnableBiometricsPrompt = false
    }
    
    func skipBiometricEnable() {
        showEnableBiometricsPrompt = false
    }
    
    // MARK: - Logout
    
    func logout() async {
        isLoading = true
        errorMessage = nil
        
        stopTokenExpirationMonitoring()
        
        do {
            try await repository.logout()
            cleanupAuth()
        } catch let error as RepositoryError {
            errorMessage = error.errorDescription
            cleanupAuth()
        } catch {
            errorMessage = "Error during logout"
            cleanupAuth()
        }
        
        isLoading = false
    }
    
    // MARK: - Session Expired Handler
    
    /// Gestisce lo stato UI quando la sessione risulta scaduta.
    private func handleSessionExpired() {
        stopTokenExpirationMonitoring()
        showSessionExpired = true
    }
    
    /// Chiude l'alert di sessione scaduta e ripristina stato non autenticato.
    func dismissSessionExpired() {
        showSessionExpired = false
        cleanupAuth()
        sessionService.resetSessionExpiredFlag()
    }
    
    // MARK: - Cleanup
    
    /// Ripulisce in modo centralizzato stato locale e credenziali persistite.
    private func cleanupAuth() {
        isAuthenticated = false
        password = ""
        isPasswordVisible = false
        hasStoredSession = false
        stopLoginLockoutTimer()
        stopTokenExpirationMonitoring()
        repository.clearAuth()
    }
    
    // MARK: - Validation
    
    private func validateLoginInput(email: String, password: String) -> String? {
        guard !email.isEmpty, !password.isEmpty else {
            return "Enter email and password."
        }
        
        guard email.count <= 254 else {
            return "Email is too long."
        }
        
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,64}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        guard predicate.evaluate(with: email) else {
            return "Enter a valid email address."
        }
        
        guard password.count <= 128 else {
            return "Password is too long."
        }
        
        return nil
    }
    
    // MARK: - Login Lockout
    
    private var isLoginLocked: Bool {
        guard let lockoutUntil else { return false }
        return Date() < lockoutUntil
    }
    
    private func registerFailedLoginAttempt() {
        failedLoginAttempts += 1
        
        guard failedLoginAttempts >= 2 else { return }
        lockoutUntil = Date().addingTimeInterval(30)
        failedLoginAttempts = 0
        startLoginLockoutTimer()
    }
    
    private func startLoginLockoutTimer() {
        stopLoginLockoutTimer()
        updateRemainingLockoutSeconds()
        
        lockoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateRemainingLockoutSeconds()
            }
        }
    }
    
    private func updateRemainingLockoutSeconds() {
        guard let lockoutUntil else {
            remainingLockoutSeconds = 0
            stopLoginLockoutTimer()
            return
        }
        
        let seconds = Int(ceil(lockoutUntil.timeIntervalSinceNow))
        if seconds <= 0 {
            self.lockoutUntil = nil
            self.remainingLockoutSeconds = 0
            stopLoginLockoutTimer()
        } else {
            self.remainingLockoutSeconds = seconds
        }
    }
    
    private func stopLoginLockoutTimer() {
        lockoutTimer?.invalidate()
        lockoutTimer = nil
    }
    
    // MARK: - Biometrics
    
    private func configureBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        canUseBiometrics = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
        
        switch context.biometryType {
        case .faceID:
            biometricButtonTitle = "Sign in with Face ID"
        case .touchID:
            biometricButtonTitle = "Sign in with Touch ID"
        default:
            biometricButtonTitle = "Sign in with biometrics"
        }
    }
    
    private func evaluateBiometricPolicy(reason: String) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            let context = LAContext()
            context.localizedCancelTitle = "Use password"
            var error: NSError?
            
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                continuation.resume(returning: false)
                return
            }
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                if let authError {
                    continuation.resume(throwing: authError)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
}
