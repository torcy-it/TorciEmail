//
//  AuthViewModel.swift
//  TorciEmail
//
//  ViewModel di autenticazione e gestione sessione JWT.
//  Coordina login/logout, refresh utente e stato di sessione scaduta.
//

import SwiftUI
import Combine

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
    
    // MARK: - Dependencies
    private let repository: AuthRepository
    private let sessionService: SessionExpirationService
    
    private var cancellables = Set<AnyCancellable>()
    private var tokenExpirationTimer: Timer?
    
    // MARK: - Init
    
    /// Dependency Injection: il ViewModel dipende da protocollo repository
    /// e da un servizio dedicato all'osservazione della scadenza sessione.
    init(
        repository: AuthRepository = AuthRepositoryImpl(),
        sessionService: SessionExpirationService = DefaultSessionExpirationService()
    ) {
        self.repository = repository
        self.sessionService = sessionService
        checkAuthStatus()
        observeSessionExpiration()
    }
    
    // MARK: - Auth Status
    
    /// Inizializza lo stato autenticazione dall'archivio locale e avvia i flussi correlati.
    private func checkAuthStatus() {
        isAuthenticated = repository.isAuthenticated()
        
        if !isAuthenticated && sessionService.isAuthenticated {
            cleanupAuth()
        } else if isAuthenticated {
            Task {
                await refreshUserInfo()
            }
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
                errorMessage = "Impossibile recuperare i dati utente"
            }
        }
    }
    
    // MARK: - Login
    
    func login() async {
         guard !userEmail.isEmpty, !password.isEmpty else {
             errorMessage = "Inserisci email e password"
             return
         }
         
         isLoading = true
         errorMessage = nil
         
         do {
             _ = try await repository.login(username: userEmail, password: password)
             isAuthenticated = true
             
             startTokenExpirationMonitoring()
         } catch let error as RepositoryError {
             errorMessage = error.errorDescription
         } catch {
             errorMessage = "Errore sconosciuto"
         }
         
         isLoading = false
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
        userEmail = ""
        password = ""
        stopTokenExpirationMonitoring()
        repository.clearAuth()
    }
}
