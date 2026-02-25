//
//  AuthRepositoryImpl.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 08/02/26.
//

import Foundation

/// Implementazione concreta di AuthRepository
/// Gestisce autenticazione e gestione token
final class AuthRepositoryImpl: AuthRepository {
    
    private let apiService: VaporAPIService
    
    init(apiService: VaporAPIService = .shared) {
        self.apiService = apiService
    }
    
    
    
    // MARK: - AuthRepository
    
    func getCurrentUser() async throws -> String {
        do {
            let response = try await apiService.getCurrentUser()
            print("Repository: Retrieved user email: \(response.email)")
            return response.email
            
        } catch let apiError as APIError {
            throw mapAPIError(apiError)
        } catch {
            throw RepositoryError.unknown
        }
    }
    
    private func extractEmailFromToken(_ token: String) -> String? {
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
              let email = json["sub"] as? String else {
            return nil
        }
        
        return email
    }
    
    func login(username: String, password: String) async throws -> String {
        do {
            let token = try await apiService.login(username: username, password: password)
            print("Repository: Login successful")
            return token
            
        } catch let apiError as APIError {
            throw mapAPIError(apiError)
        } catch {
            throw RepositoryError.unknown
        }
    }
    
    func logout() async throws {
        do {
            try await apiService.logout()
            print("Repository: Logout successful")
            
        } catch let apiError as APIError {
            // Anche se il logout fallisce, pulisci comunque il token locale
            apiService.clearAuth()
            throw mapAPIError(apiError)
        } catch {
            apiService.clearAuth()
            throw RepositoryError.unknown
        }
    }

    
    func isAuthenticated() -> Bool {
        return apiService.isAuthenticated && !isTokenExpired()
    }
    
    func clearAuth() {
        apiService.clearAuth()
    }
    
    func getTokenExpirationDate() -> Date? {
        guard let token = apiService.authToken else { return nil }
        return extractExpirationDate(from: token)
    }
    
    func isTokenExpired() -> Bool {
        guard let expirationDate = getTokenExpirationDate() else {
            return true
        }
        return expirationDate <= Date()
    }
    
    // MARK: - Private Helpers
    
    private func mapAPIError(_ error: APIError) -> RepositoryError {
        switch error {
        case .unauthorized:
            return .unauthorized
        case .httpError(_, let message):
            return .serverError(message: message ?? "Errore del server")
        case .networkError:
            return .networkError
        case .decodingError:
            return .invalidData
        default:
            return .unknown
        }
    }
    
    /// Estrae la data di scadenza dal token JWT
    private func extractExpirationDate(from token: String) -> Date? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }
        
        let payloadPart = String(parts[1])
        
        // Base64 URL decode
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
}
