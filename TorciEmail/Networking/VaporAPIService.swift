//
//  VaporAPIService.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//

import Foundation

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
            return "Credenziali non valide. Riprova."
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

class VaporAPIService {
    static let shared = VaporAPIService()
    
    private let baseURL: String
    private(set) var authToken: String?
    
    private init(baseURL: String = "http://localhost:8080") {
        self.baseURL = baseURL
        // Carica token salvato se esiste
        self.authToken = KeychainManager.shared.getToken()
    }
    
    // MARK: - Authentication
    
    func login(username: String, password: String) async throws -> String {
        let request = LoginRequest(username: username, password: password)
        let response: LoginResponse = try await post(
            endpoint: "/login",
            body: request,
            requiresAuth: false
        )
        
        // Salva token
        self.authToken = response.token
        KeychainManager.shared.saveToken(response.token)
        
        print("✅ Login successful, token saved")
        
        return response.token
    }
    
    func logout() async throws {
        let _: LogoutResponse = try await post(
            endpoint: "/logout",
            body: EmptyBody(),
            requiresAuth: true
        )
        
        // Rimuovi token
        self.authToken = nil
        KeychainManager.shared.deleteToken()
        
        print("✅ Logout successful, token removed")
    }
    
    var isAuthenticated: Bool {
        return authToken != nil
    }
    
    // MARK: - EviMails
    
    func queryEviMails(limit: Int = 100, offset: Int? = nil) async throws -> EviMailQueryResponse {
        let request = EviMailQueryRequest(limit: limit, offset: offset)
        
        print("📤 Querying EviMails - limit: \(limit), offset: \(offset ?? 0)")
        
        let response: EviMailQueryResponse = try await post(
            endpoint: "/evimails/query",
            body: request,
            requiresAuth: true
        )
        
        print("📥 Received \(response.results.count) emails (total: \(response.totalMatches))")
        
        return response
    }
    
    func getEviMail(id: String) async throws -> EviMail {
        print("📤 Fetching EviMail with ID: \(id)")
        
        let email: EviMail = try await get(
            endpoint: "/evimails/\(id)",
            requiresAuth: true
        )
        
        print("📥 Received EviMail: \(email.subject ?? "No subject")")
        
        return email
    }
    
    // MARK: - Generic HTTP Methods
    
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
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        
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
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print("❌ Network error: \(error)")
            throw APIError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📡 Response status: \(httpResponse.statusCode)")
        
        // Gestione errori HTTP
        guard (200...299).contains(httpResponse.statusCode) else {
            // Prova a decodificare messaggio di errore
            let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            
            if httpResponse.statusCode == 401 {
                // Token scaduto o non valido
                self.authToken = nil
                KeychainManager.shared.deleteToken()
                throw APIError.unauthorized
            }
            
            throw APIError.httpError(
                statusCode: httpResponse.statusCode,
                message: errorMessage?.reason
            )
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(R.self, from: data)
            return result
        } catch {
            print("❌ Decoding error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Response JSON: \(jsonString)")
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
