//
//  EviMail.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//

import Foundation

struct EviMail: Codable, Hashable {
    let uniqueId: String?
    let issuer: Contact?
    let recipient: Contact?
    let subject: String?
    let body: String?
    let state: String?
    
    // Date strings
    let creationDate: String?
    let lastStateChangeDate: String?
    let newOn: String?
    let readyOn: String?
    let sentOn: String?
    let dispatchedOn: String?
    let deliveredOn: String?
    let readOn: String?
    let repliedOn: String?
    let acceptedOn: String?
    let expiredOn: String?
    
    let outcome: String?
    let timeToLive: Int?
    let costCentre: String?
    let onlineRetentionPeriod: Int?
    let sourceChannel: String?
    
    let carbonCopy: [CarbonCopyRecipient]?
    let affidavitKinds: [String]?
    
    let xmissionResult: Bool?
    let xmissionSummary: String?
    let from: String?
    let customLayoutLogoUrl: String?
    let siteName: String?
    
    // AGGIUNGI CodingKeys esplicite
    enum CodingKeys: String, CodingKey {
        case uniqueId
        case issuer
        case recipient
        case subject
        case body
        case state
        case creationDate
        case lastStateChangeDate
        case newOn
        case readyOn
        case sentOn
        case dispatchedOn
        case deliveredOn
        case readOn
        case repliedOn
        case acceptedOn
        case expiredOn
        case outcome
        case timeToLive
        case costCentre
        case onlineRetentionPeriod
        case sourceChannel
        case carbonCopy
        case affidavitKinds
        case xmissionResult
        case xmissionSummary
        case from
        case customLayoutLogoUrl
        case siteName
    }
}

struct Contact: Codable, Hashable {
    let legalName: String?
    let emailAddress: String
    
    enum CodingKeys: String, CodingKey {
        case legalName
        case emailAddress
    }
}

struct CarbonCopyRecipient: Codable, Hashable {
    let name: String
    let emailAddress: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case emailAddress
    }
    
    // Implementazione esplicita di Hashable per evitare conflitti
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(emailAddress)
    }
    
    static func == (lhs: CarbonCopyRecipient, rhs: CarbonCopyRecipient) -> Bool {
        lhs.name == rhs.name && lhs.emailAddress == rhs.emailAddress
    }
}
