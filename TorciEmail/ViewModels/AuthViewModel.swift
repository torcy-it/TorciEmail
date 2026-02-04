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
    
    private let apiService = VaporAPIService.shared
    private var cancellables = Set<AnyCancellable>()
    private var tokenExpirationTimer: Timer?
    
    private init() {
        checkAuthStatus()
        observeSessionExpiration()
    }
    
    // MARK: - Auth Status
    
    private func checkAuthStatus() {
        isAuthenticated = apiService.isAuthenticated && !isTokenExpired()
        
        if !isAuthenticated && apiService.isAuthenticated {
            print("Token expired on app launch, cleaning up...")
            cleanupAuth()
        } else if isAuthenticated {
            // Avvia il controllo automatico se autenticato
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
    

    
    private func startTokenExpirationMonitoring() {
        // Stoppa il timer precedente se esiste
        stopTokenExpirationMonitoring()
        
        guard let expirationDate = getTokenExpirationDate() else {
            print("Cannot get token expiration date")
            return
        }
        
        let now = Date()
        let timeUntilExpiration = expirationDate.timeIntervalSince(now)
        
        print("Token expires at: \(expirationDate)")
        print("Time until expiration: \(Int(timeUntilExpiration)) seconds")
        
        // Se il token è già scaduto
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
        
        if isTokenExpired() {
            print("Token expired detected by timer!")
            stopTokenExpirationMonitoring()
            handleSessionExpired()
        } else {
            print("Token still valid")
        }
    }
    
    // MARK: - Token Expiration Check
    
    private func isTokenExpired() -> Bool {
        guard let expirationDate = getTokenExpirationDate() else {
            return true
        }
        
        return expirationDate <= Date()
    }
    
    private func getTokenExpirationDate() -> Date? {
        guard let token = apiService.authToken else { return nil }
        
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }
        
        let payloadPart = String(parts[1])
        
        var base64 = payloadPart
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        while base64.count % 4 != 0 {
            base64.append("=")
        }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return nil
        }
        
        return Date(timeIntervalSince1970: exp)
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
            _ = try await apiService.login(username: username, password: password)
            isAuthenticated = true
            
            
            startTokenExpirationMonitoring()
            
            print("Login successful")
        } catch let error as APIError {
            errorMessage = error.errorDescription
            print("Login failed: \(error.errorDescription ?? "Unknown error")")
        } catch {
            errorMessage = "Errore sconosciuto"
            print("Login failed: \(error)")
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
            try await apiService.logout()
            cleanupAuth()
            print("Logout successful")
        } catch let error as APIError {
            errorMessage = error.errorDescription
            print("Logout failed: \(error.errorDescription ?? "Unknown error")")
            cleanupAuth()
        } catch {
            errorMessage = "Errore durante il logout"
            print("Logout failed: \(error)")
            cleanupAuth()
        }
        
        isLoading = false
    }
    
    // MARK: - Session Expired Handler
    
    private func handleSessionExpired() {
        print("Session expired - showing alert")
        
        stopTokenExpirationMonitoring()
        
        // Mostra l'alert
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
    }
}

