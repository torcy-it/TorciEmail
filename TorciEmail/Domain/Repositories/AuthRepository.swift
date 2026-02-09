//
//  AuthRepository.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 08/02/26.
//

import Foundation

/// Protocol che definisce le operazioni di autenticazione
protocol AuthRepository {
    /// Effettua il login con username e password
    /// - Parameters:
    ///   - username: Username dell'utente
    ///   - password: Password dell'utente
    /// - Returns: Token JWT di autenticazione
    /// - Throws: RepositoryError in caso di errore
    func login(username: String, password: String) async throws -> String
    
    /// Effettua il logout dell'utente corrente
    /// - Throws: RepositoryError in caso di errore
    func logout() async throws
    
    /// Verifica se l'utente è autenticato
    /// - Returns: true se esiste un token valido, false altrimenti
    func isAuthenticated() -> Bool
    
    /// Pulisce i dati di autenticazione (logout locale)
    func clearAuth()
    
    /// Ottiene la data di scadenza del token corrente
    /// - Returns: Data di scadenza o nil se non c'è token
    func getTokenExpirationDate() -> Date?
    
    /// Verifica se il token è scaduto
    /// - Returns: true se il token è scaduto o non esiste
    func isTokenExpired() -> Bool
}
