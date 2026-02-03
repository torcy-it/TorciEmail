//
//  EviMailQueryResponse.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//


struct EviMailQueryResponse: Codable {
    let totalMatches: Int
    let results: [EviMail]
}
