//
//  EmailRepository.swift
//  CertfiedEmail
//
//  Definisce il contratto del layer Repository per le operazioni email.
//  Il ViewModel dipende da questo protocollo per restare disaccoppiato
//  dai dettagli di networking e mapping dati.
//

import Foundation

/// Contratto applicativo per le operazioni di lettura e invio EviMail.
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
    
    /// Invia una nuova email certificata con allegato locale.
    /// - Parameters:
    ///   - draft: Bozza dell'email da inviare.
    ///   - fileURL: URL del file da allegare.
    ///   - fileName: Nome file opzionale da mostrare lato server/utente.
    /// - Returns: ID dell'email inviata (eviId).
    /// - Throws: RepositoryError in caso di errore o validazione fallita.
    func sendEmailWithAttachment(
        _ draft: EmailDraft,
        fileURL: URL,
        fileName: String?
    ) async throws -> String
}
// MARK: - Repository Error

/// Errori del layer repository, mappati in messaggi user-friendly.
enum RepositoryError: LocalizedError {
    case unauthorized
    case emailNotFound
    case invalidData
    case networkError
    case serverError(message: String)
    case fileTooLarge
    case unsupportedFileType
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Error please log in again."
        case .emailNotFound:
            return "Email not found."
        case .invalidData:
            return "Invalid data."
        case .networkError:
            return "Connection error. Check your network."
        case .serverError(let message):
            return message
        case .fileTooLarge:
            return "The selected file is too large (max 10 MB)."
        case .unsupportedFileType:
            return "Unsupported file format. Use PDF, DOC, DOCX, JPG, PNG, or ZIP."
        case .unknown:
            return "Unknown error."
        }
    }
}
