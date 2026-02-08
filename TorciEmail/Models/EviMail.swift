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
    
    let affidavits: [Affidavit]?
    let attachments: [EviMailAttachment]?
    let acceptOrRejectComments: String?
    
    let xmissionResult: Bool?
    let xmissionSummary: String?
    let from: String?
    let customLayoutLogoUrl: String?
    let siteName: String?
    
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
        case affidavits
        case attachments
        case acceptOrRejectComments
        case xmissionResult
        case xmissionSummary
        case from
        case customLayoutLogoUrl
        case siteName
    }
}

// MARK: - Contact

struct Contact: Codable, Hashable {
    let legalName: String?
    let emailAddress: String
}

// MARK: - CarbonCopyRecipient

struct CarbonCopyRecipient: Codable, Hashable {
    let name: String
    let emailAddress: String
}

// MARK: - Affidavit (Certificato Legale)

struct Affidavit: Codable, Hashable, Identifiable {
    let uniqueId: String
    let date: String?
    let evidenceUniqueId: String?
    let partyUniqueId: String?
    let description: String?
    let kind: String
    let additionalData: [String: String]?
    
    // Conformità a Identifiable
    var id: String { uniqueId }
    
    enum CodingKeys: String, CodingKey {
        case uniqueId
        case date
        case evidenceUniqueId
        case partyUniqueId
        case description
        case kind
        case additionalData
    }
}

// MARK: - EviMailAttachment (dall'API)

struct EviMailAttachment: Codable, Hashable, Identifiable {
    let uniqueId: String
    let creationDate: String?
    let evidenceUniqueId: String?
    let contentId: String?
    let displayName: String
    let filename: String
    let mimeType: String
    let contentDisposition: String?
    let contentEncoding: String?
    let contentLength: Int?
    let hash: String?
    
    // Conformità a Identifiable
    var id: String { uniqueId }
    
    enum CodingKeys: String, CodingKey {
        case uniqueId
        case creationDate
        case evidenceUniqueId
        case contentId
        case displayName
        case filename
        case mimeType
        case contentDisposition
        case contentEncoding
        case contentLength
        case hash
    }
}
