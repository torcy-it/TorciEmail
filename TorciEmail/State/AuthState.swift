//
//  LoginState.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AuthState: ObservableObject {
    @Published private(set) var isAuthenticated = false
    @Published private(set) var token: String?
    
    private let tokenKey = "auth_token"
    
    init() {
        // Recupera token salvato
        if let savedToken = UserDefaults.standard.string(forKey: tokenKey) {
            self.token = savedToken
            self.isAuthenticated = true
        }
    }
    
    func login(token: String) {
        self.token = token
        self.isAuthenticated = true
        
        // Salva token in UserDefaults (o Keychain per più sicurezza)
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    func logout() {
        self.token = nil
        self.isAuthenticated = false
        
        // Rimuovi token salvato
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
