//
//  VaporAPIService.swift
//  TorciEmail
//
//  Client HTTP centralizzato verso backend Vapor.
//  Gestisce autenticazione, endpoint EviMail e mappatura errori di rete.
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
        case .networkError(let error):
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    return "Nessuna connessione o accesso rete locale negato. Verifica Wi-Fi e permessi rete locale."
                case .cannotConnectToHost:
                    return "Impossibile raggiungere il server. Verifica IP, porta 8080 e server avviato."
                case .timedOut:
                    return "Timeout di connessione. Il server potrebbe non rispondere."
                case .appTransportSecurityRequiresSecureConnection:
                    return "Connessione bloccata da sicurezza iOS (ATS)."
                default:
                    return "Errore di connessione (\(urlError.code.rawValue)). Verifica la tua rete."
                }
            }
            return "Errore di connessione. Verifica la tua rete."
        }
    }
}

/// Servizio networking principale dell'app.
final class VaporAPIService: ObservableObject {
    static let shared = VaporAPIService()
    
    private let baseURL: String
    private(set) var authToken: String?
    private let urlSession: URLSession
    
    @Published var sessionExpired: Bool = false
    
    private init(baseURL: String = AppConfig.apiBaseURL) {
        self.baseURL = Self.resolveBaseURL(baseURL)
        self.authToken = KeychainManager.shared.getToken()
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        self.urlSession = URLSession(configuration: configuration)
    }
    
    private static func resolveBaseURL(_ configuredURL: String) -> String {
#if targetEnvironment(simulator)
        return configuredURL
#else
        // On a physical device localhost points to the phone itself.
        var resolved = configuredURL
        resolved = resolved.replacingOccurrences(of: "http://localhost:8080", with: "http://172.20.10.4:8080")
        resolved = resolved.replacingOccurrences(of: "http://127.0.0.1:8080", with: "http://172.20.10.4:8080")
        resolved = resolved.replacingOccurrences(of: "http://[::1]:8080", with: "http://172.20.10.4:8080")
        return resolved
#endif
    }
    
    var isAuthenticated: Bool {
        return authToken != nil
    }
    
    /// Ritorna le informazioni utente corrente usando il token JWT attivo.
    func getCurrentUser() async throws -> UserInfoResponse {
        let response: UserInfoResponse = try await get(
            endpoint: "/me",
            requiresAuth: true
        )
        return response
    }
    
    // MARK: - Authentication
    
    /// Esegue login e persiste il token nel keychain.
    func login(username: String, password: String) async throws -> String {
        let request = LoginRequest(username: username, password: password)
        let response: LoginResponse = try await post(
            endpoint: "/login",
            body: request,
            requiresAuth: false
        )
        
        self.authToken = response.token
        KeychainManager.shared.saveToken(response.token)
        
        return response.token
    }
    
    /// Esegue logout remoto e pulizia locale credenziali.
    func logout() async throws {
        let _: LogoutResponse = try await post(
            endpoint: "/logout",
            body: EmptyBody(),
            requiresAuth: true
        )
        
        clearAuth()
    }
    
    
    /// Svuota le credenziali locali dell'utente corrente.
    func clearAuth() {
        self.authToken = nil
        KeychainManager.shared.deleteToken()
    }
    
    // MARK: - EviMails
    
    /// Recupera la mailbox completa dal backend.
    func queryAllEviMails() async throws -> EviMailQueryResponse {
        let response: EviMailQueryResponse = try await post(
            endpoint: "/evimails/query-all",
            body: EmptyBody(),
            requiresAuth: true
        )
        return response
    }
    
    /// Recupera i dettagli completi di una singola EviMail.
    func getEviMail(id: String) async throws -> EviMail {
        struct GetByIdRequest: Encodable {
            let id: String
            let includeAffidavits: Bool?
            let includeAttachments: Bool?
            let includeAttachmentBlobs: Bool?
            let includeAffidavitBlobs: Bool?
            
            enum CodingKeys: String, CodingKey {
                case id
                case includeAffidavits = "IncludeAffidavits"
                case includeAttachments = "IncludeAttachments"
                case includeAttachmentBlobs = "IncludeAttachmentBlobs"
                case includeAffidavitBlobs = "IncludeAffidavitBlobs"
            }
        }
        
        let requestBody = GetByIdRequest(
            id: id,
            includeAffidavits: true,
            includeAttachments: true,
            includeAttachmentBlobs: true,
            includeAffidavitBlobs: true
        )
        
        let rawData = try await postBinary(
            endpoint: "/evimails/get-by-id",
            body: requestBody,
            requiresAuth: true
        )
        let email = try JSONDecoder().decode(EviMail.self, from: rawData)
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
        let data = try await performRawRequest(request)
        
        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

// MARK: - Modelli di supporto

struct EmptyBody: Codable {}

struct ErrorResponse: Codable {
    let error: Bool
    let reason: String
}

extension VaporAPIService {
    
    /// Esegue una richiesta HTTP e restituisce i dati grezzi, gestendo la mappatura errori.
    func performRawRequest(_ request: URLRequest) async throws -> Data {
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
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
        
        return data
    }
    
    /// POST con corpo JSON, restituisce dati grezzi (usato per download binari).
    func postBinary<T: Encodable>(
        endpoint: String,
        body: T,
        requiresAuth: Bool
    ) async throws -> Data {
        var request = try createRequest(
            endpoint: endpoint,
            method: "POST",
            requiresAuth: requiresAuth
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        return try await performRawRequest(request)
    }
    
    /// Invia un corpo multipart già costruito, con content-type personalizzato.
    func sendMultipart(
        endpoint: String,
        bodyData: Data,
        contentType: String,
        requiresAuth: Bool
    ) async throws -> Data {
        var request = try createRequest(
            endpoint: endpoint,
            method: "POST",
            requiresAuth: requiresAuth
        )
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = contentType
        request.allHTTPHeaderFields = headers
        request.httpBody = bodyData
        
        return try await performRawRequest(request)
    }
}

extension VaporAPIService {
    
    /// Invia una nuova EviMail certificata
    /// - Parameter request: Richiesta di invio con tutti i dati
    /// - Returns: Risposta con `eviId` dell'email inviata.
    /// - Throws: APIError in caso di errore
    func submitEviMail(_ request: EviMailSubmitRequest) async throws -> EviMailSubmitResponse {
        let response: EviMailSubmitResponse = try await post(
            endpoint: "/evimails/submit",
            body: request,
            requiresAuth: true
        )
        return response
    }
}
