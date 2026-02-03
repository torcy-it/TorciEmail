//
//  AuthViewModel.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    private let apiService = VaporAPIService.shared
    
    init() {
        // Controlla se c'è già un token salvato
        isAuthenticated = apiService.isAuthenticated
    }
    
    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Inserisci email e password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await apiService.login(username: email, password: password)
            isAuthenticated = true
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
    
    func logout() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.logout()
            isAuthenticated = false
            email = ""
            password = ""
            print("Logout successful")
        } catch let error as APIError {
            errorMessage = error.errorDescription
            print("Logout failed: \(error.errorDescription ?? "Unknown error")")
        } catch {
            errorMessage = "Errore durante il logout"
            print("Logout failed: \(error)")
        }
        
        isLoading = false
    }
}
