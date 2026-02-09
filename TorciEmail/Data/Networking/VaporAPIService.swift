//
//  VaporAPIService.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//

import Foundation
import Combine

enum APIError: LocalizedError {
    case invalidURL
    case unauthorized
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL non valido"
        case .unauthorized:
            return "Sessione scaduta. Effettua nuovamente il login."
        case .invalidResponse:
            return "Risposta del server non valida"
        case .httpError(let code, let message):
            if let message = message {
                return "Errore \(code): \(message)"
            }
            return "Errore HTTP \(code)"
        case .decodingError(let error):
            return "Errore nella decodifica dei dati: \(error.localizedDescription)"
        case .networkError:
            return "Errore di connessione. Verifica la tua rete."
        }
    }
}

class VaporAPIService: ObservableObject {
    static let shared = VaporAPIService()
    
    private let baseURL: String
    private(set) var authToken: String?
    private let urlSession: URLSession  // Aggiungi questa proprietà
    
    @Published var sessionExpired: Bool = false
    
    private init(baseURL: String = "http://localhost:8080") {
        self.baseURL = baseURL
        self.authToken = KeychainManager.shared.getToken()
        
        // Configura URLSession con timeout più lungo
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60  // 60 secondi
        configuration.timeoutIntervalForResource = 120  // 2 minuti
        self.urlSession = URLSession(configuration: configuration)
    }
    
    var isAuthenticated: Bool {
        return authToken != nil
    }
    
    // MARK: - Authentication
    
    func login(username: String, password: String) async throws -> String {
        let request = LoginRequest(username: username, password: password)
        let response: LoginResponse = try await post(
            endpoint: "/login",
            body: request,
            requiresAuth: false
        )
        
        self.authToken = response.token
        KeychainManager.shared.saveToken(response.token)
        
        print("Login successful, token saved")
        
        return response.token
    }
    
    func logout() async throws {
        let _: LogoutResponse = try await post(
            endpoint: "/logout",
            body: EmptyBody(),
            requiresAuth: true
        )
        
        clearAuth()
        print("Logout successful")
    }
    
    func clearAuth() {
        self.authToken = nil
        KeychainManager.shared.deleteToken()
    }
    
    // MARK: - EviMails
    
    func queryAllEviMails() async throws -> EviMailQueryResponse {
        print("Querying ALL EviMails")
        
        let response: EviMailQueryResponse = try await post(
            endpoint: "/evimails/query-all",
            body: EmptyBody(),
            requiresAuth: true
        )
        
        print("Received \(response.results.count) emails")
        
        return response
    }
    
    func getEviMail(id: String) async throws -> EviMail {
        print("Fetching EviMail: \(id)")
        
        let email: EviMail = try await get(
            endpoint: "/evimails/\(id)",
            requiresAuth: true
        )
        
        print("Received EviMail")
        
        return email
    }
    
    // MARK: - HTTP Methods
    
    private func post<T: Encodable, R: Decodable>(
        endpoint: String,
        body: T,
        requiresAuth: Bool
    ) async throws -> R {
        var request = try createRequest(
            endpoint: endpoint,
            method: "POST",
            requiresAuth: requiresAuth
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        return try await performRequest(request)
    }
    
    private func get<R: Decodable>(
        endpoint: String,
        requiresAuth: Bool
    ) async throws -> R {
        let request = try createRequest(
            endpoint: endpoint,
            method: "GET",
            requiresAuth: requiresAuth
        )
        return try await performRequest(request)
    }
    
    private func createRequest(
        endpoint: String,
        method: String,
        requiresAuth: Bool
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if requiresAuth {
            guard let token = authToken else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func performRequest<R: Decodable>(_ request: URLRequest) async throws -> R {
        let (data, response): (Data, URLResponse)
        
        do {
            // Usa urlSession invece di URLSession.shared
            (data, response) = try await urlSession.data(for: request)
        } catch {
            print("Network error: \(error)")
            throw APIError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("Status: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                print("401 Unauthorized - Token expired")
                
    
                await MainActor.run {
                    self.sessionExpired = true
                }
                
                throw APIError.unauthorized
            }
            
            let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw APIError.httpError(
                statusCode: httpResponse.statusCode,
                message: errorMessage?.reason
            )
        }
        
        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response: \(jsonString)")
            }
            throw APIError.decodingError(error)
        }
    }
}

// MARK: - Helper Models

struct EmptyBody: Codable {}

struct ErrorResponse: Codable {
    let error: Bool
    let reason: String
}

extension VaporAPIService {
    
    /// Invia una nuova EviMail certificata
    /// - Parameter request: Richiesta di invio con tutti i dati
    /// - Returns: Response con eviId dell'email inviata
    /// - Throws: APIError in caso di errore
    func submitEviMail(_ request: EviMailSubmitRequest) async throws -> EviMailSubmitResponse {
        print("Submitting EviMail to: \(request.recipient.emailAddress)")
        
        let response: EviMailSubmitResponse = try await post(
            endpoint: "/evimails/submit",
            body: request,
            requiresAuth: true
        )
        
        print("✅ EviMail submitted: \(response.eviId)")
        
        return response
    }
}
