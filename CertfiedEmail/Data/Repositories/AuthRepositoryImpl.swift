//
//  AuthRepositoryImpl.swift
//  CertfiedEmail
//
//  Implementazione repository autenticazione.
//  Gestisce login/logout, stato auth e parsing scadenza JWT.
//

import Foundation

/// Implementazione concreta di AuthRepository
/// Gestisce autenticazione e gestione token
final class AuthRepositoryImpl: AuthRepository {
    
    private let apiService: VaporAPIService
    
    /// Crea il repository con service API iniettabile.
    init(apiService: VaporAPIService = .shared) {
        self.apiService = apiService
    }
    
    
    
    // MARK: - AuthRepository
    
    func getCurrentUser() async throws -> String {
        do {
            let response = try await apiService.getCurrentUser()
            return response.email
            
        } catch let apiError as APIError {
            throw mapAPIError(apiError)
        } catch {
            throw RepositoryError.unknown
        }
    }
    
    /// Esegue login verso backend e ritorna token JWT.
    func login(username: String, password: String) async throws -> String {
        do {
            let token = try await apiService.login(username: username, password: password)
            return token
            
        } catch let apiError as APIError {
            throw mapAPIError(apiError)
        } catch {
            throw RepositoryError.unknown
        }
    }
    
    /// Esegue logout remoto e pulizia locale in caso di errore.
    func logout() async throws {
        do {
            try await apiService.logout()
            
        } catch let apiError as APIError {
            // Anche se il logout fallisce, pulisci comunque il token locale
            apiService.clearAuth()
            throw mapAPIError(apiError)
        } catch {
            apiService.clearAuth()
            throw RepositoryError.unknown
        }
    }

    
    /// Determina se la sessione locale e ancora valida.
    func isAuthenticated() -> Bool {
        return apiService.isAuthenticated && !isTokenExpired()
    }
    
    /// Pulisce le credenziali locali.
    func clearAuth() {
        apiService.clearAuth()
    }
    
    /// Ritorna la data di scadenza JWT se disponibile.
    func getTokenExpirationDate() -> Date? {
        guard let token = apiService.authToken else { return nil }
        return extractExpirationDate(from: token)
    }
    
    /// Verifica se il token attuale risulta scaduto.
    func isTokenExpired() -> Bool {
        guard let expirationDate = getTokenExpirationDate() else {
            return true
        }
        return expirationDate <= Date()
    }
    
    // MARK: - Private Helpers
    
    /// Mappa errori API in errori di dominio repository.
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
