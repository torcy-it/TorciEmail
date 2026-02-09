//
//  AuthViewModel.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//

import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    static let shared = AuthViewModel()
    
    // MARK: - Published Properties
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var showSessionExpired: Bool = false
    
    // MARK: - Dependencies
    private let repository: AuthRepository
    private let apiService = VaporAPIService.shared  // Solo per observare sessionExpired
    
    private var cancellables = Set<AnyCancellable>()
    private var tokenExpirationTimer: Timer?
    
    // MARK: - Init
    
    /// Dependency Injection: il ViewModel dipende dal protocollo
    init(repository: AuthRepository = AuthRepositoryImpl()) {
        self.repository = repository
        checkAuthStatus()
        observeSessionExpiration()
    }
    
    // MARK: - Auth Status
    
    private func checkAuthStatus() {
        isAuthenticated = repository.isAuthenticated()
        
        if !isAuthenticated && apiService.isAuthenticated {
            print("Token expired on app launch, cleaning up...")
            cleanupAuth()
        } else if isAuthenticated {
            startTokenExpirationMonitoring()
        }
    }
    
    // MARK: - Session Expiration Observer
    
    private func observeSessionExpiration() {
        apiService.$sessionExpired
            .receive(on: DispatchQueue.main)
            .sink { [weak self] expired in
                if expired {
                    self?.handleSessionExpired()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Token Expiration Monitoring
    
    private func startTokenExpirationMonitoring() {
        stopTokenExpirationMonitoring()
        
        guard let expirationDate = repository.getTokenExpirationDate() else {
            print("Cannot get token expiration date")
            return
        }
        
        let now = Date()
        let timeUntilExpiration = expirationDate.timeIntervalSince(now)
        
        print("Token expires at: \(expirationDate)")
        print("Time until expiration: \(Int(timeUntilExpiration)) seconds")
        
        if timeUntilExpiration <= 0 {
            print("Token already expired!")
            handleSessionExpired()
            return
        }
        
        // Controlla ogni 30 secondi
        tokenExpirationTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkTokenExpiration()
            }
        }
        
        print("Token expiration monitoring started (checks every 30s)")
    }
    
    private func stopTokenExpirationMonitoring() {
        tokenExpirationTimer?.invalidate()
        tokenExpirationTimer = nil
        print("Token expiration monitoring stopped")
    }
    
    private func checkTokenExpiration() {
        print("Checking token expiration...")
        
        if repository.isTokenExpired() {
            print("Token expired detected by timer!")
            stopTokenExpirationMonitoring()
            handleSessionExpired()
        } else {
            print("Token still valid")
        }
    }
    
    // MARK: - Login
    
    func login() async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Inserisci email e password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        print("Attempting login for: \(username)")
        
        do {
            // Usa il repository invece dell'apiService
            _ = try await repository.login(username: username, password: password)
            isAuthenticated = true
            
            startTokenExpirationMonitoring()
            
            print("Login successful")
        } catch let error as RepositoryError {
            errorMessage = error.errorDescription
            print("Login failed: \(error.errorDescription ?? "Unknown")")
        } catch {
            errorMessage = "Errore sconosciuto"
            print("Unexpected error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Logout
    
    func logout() async {
        isLoading = true
        errorMessage = nil
        
        stopTokenExpirationMonitoring()
        
        print("Attempting logout")
        
        do {
            // Usa il repository
            try await repository.logout()
            cleanupAuth()
            print("Logout successful")
        } catch let error as RepositoryError {
            errorMessage = error.errorDescription
            print("Logout failed: \(error.errorDescription ?? "Unknown")")
            cleanupAuth()
        } catch {
            errorMessage = "Errore durante il logout"
            print("Unexpected error: \(error)")
            cleanupAuth()
        }
        
        isLoading = false
    }
    
    // MARK: - Session Expired Handler
    
    private func handleSessionExpired() {
        print("Session expired - showing alert")
        
        stopTokenExpirationMonitoring()
        showSessionExpired = true
    }
    
    func dismissSessionExpired() {
        print("User dismissed session expired alert")
        
        showSessionExpired = false
        cleanupAuth()
        apiService.sessionExpired = false
    }
    
    // MARK: - Cleanup
    
    private func cleanupAuth() {
        isAuthenticated = false
        username = ""
        password = ""
        stopTokenExpirationMonitoring()
        repository.clearAuth()
    }
}
