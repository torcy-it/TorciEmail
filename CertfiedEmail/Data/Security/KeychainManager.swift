//
//  KeychainManager.swift
//  CertfiedEmail
//
//  Gestore minimale per persistenza sicura del token JWT nel Keychain.
//

import Foundation
import Security

/// Gestisce salvataggio, lettura e cancellazione del token in Keychain.
final class KeychainManager {
    static let shared = KeychainManager()
    private let tokenKey = "com.torciemail.authToken"
    private let service = Bundle.main.bundleIdentifier ?? "com.torciemail.app"
    
    private init() {
        // Intentionally empty: enforces singleton usage via `shared`.
    }
    
    /// Salva il token JWT nel keychain sovrascrivendo eventuale valore precedente.
    func saveToken(_ token: String) {
        let data = Data(token.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            // Stronger protection: readable only when the device is unlocked,
            // and never migrates to another device via backup restore.
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            assertionFailure("Failed to save token in Keychain. Status: \(status)")
        }
    }
    
    /// Legge il token JWT dal keychain.
    /// - Returns: Token se presente, altrimenti `nil`.
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    /// Rimuove il token JWT dal keychain.
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
