//
//  EmailRepository.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 08/02/26.
//

import Foundation

/// Protocol che definisce le operazioni per gestire le email
/// Il ViewModel dipende solo da questo protocollo, non dall'implementazione
protocol EmailRepository {
    /// Recupera tutte le email dell'utente
    /// - Returns: Array di EmailItem (modello di dominio)
    /// - Throws: RepositoryError in caso di errore
    func getAllEmails() async throws -> [EmailItem]
    
    /// Recupera una singola email per ID
    /// - Parameter id: ID dell'email da recuperare
    /// - Returns: EmailItem completo con tutti i dettagli
    /// - Throws: RepositoryError se l'email non esiste o c'è un errore
    func getEmail(id: String) async throws -> EmailItem
    
    /// Invia una nuova email certificata
    /// - Parameter draft: Bozza dell'email da inviare
    /// - Returns: ID dell'email inviata (eviId)
    /// - Throws: RepositoryError in caso di errore
    func sendEmail(_ draft: EmailDraft) async throws -> String
}
// MARK: - Repository Error

/// Errori specifici del repository (astrae gli errori dell'API)
enum RepositoryError: LocalizedError {
    case unauthorized
    case emailNotFound
    case invalidData
    case networkError
    case serverError(message: String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Sessione scaduta. Effettua nuovamente il login."
        case .emailNotFound:
            return "Email non trovata."
        case .invalidData:
            return "Dati non validi."
        case .networkError:
            return "Errore di connessione. Verifica la tua rete."
        case .serverError(let message):
            return message
        case .unknown:
            return "Errore sconosciuto."
        }
    }
}
