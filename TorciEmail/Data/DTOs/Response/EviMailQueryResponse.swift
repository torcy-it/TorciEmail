//
//  EviMailQueryResponse.swift
//  TorciEmail
//
//  DTO risposta query mailbox.
//


/// Risultato paginato/aggregato della query EviMail.
struct EviMailQueryResponse: Codable {
    let totalMatches: Int
    let results: [EviMail]
}
