//
//  UserInfoResponse.swift
//  TorciEmail
//
//  DTO risposta endpoint utente corrente.
//

/// Dati minimi profilo utente autenticato.
struct UserInfoResponse: Codable {
    let email: String
}
