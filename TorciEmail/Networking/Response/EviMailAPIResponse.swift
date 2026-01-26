//
//  EviMailAPIResponse.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 24/01/26.
//

import Foundation

// MARK: - API Response Models
struct EviMailAPIResponse: Codable {
    let totalMatches: Int
    let results: [EviMailResult]
    
    enum CodingKeys: String, CodingKey {
        case totalMatches = "TotalMatches"
        case results = "Results"
    }
}

struct EviMailResult: Codable {
    let uniqueId: String
    let linkedId: String?
    let lookupKey: String?
    let issuer: ContactInfo
    let recipient: ContactInfo
    let carbonCopy: [ContactInfo]?
    let subject: String
    let body: String
    let state: String
    let outcome: String
    let creationDate: String
    let lastStateChangeDate: String
    let affidavits: [APIAffidavit]
    let attachments: [APIAttachment]
    let acceptOrRejectComments: String?
    let timeToLive: Int?
    let onlineRetentionPeriod: Int?
    let notaryRetentionPeriod: Int?
    let notaryProfile: String?
    let sourceChannel: String?
    let allowRefusal: Bool?
    let affidavitKinds: [String]?
    
    enum CodingKeys: String, CodingKey {
        case uniqueId = "UniqueId"
        case linkedId = "LinkedId"
        case lookupKey = "LookupKey"
        case issuer = "Issuer"
        case recipient = "Recipient"
        case carbonCopy = "CarbonCopy"
        case subject = "Subject"
        case body = "Body"
        case state = "State"
        case outcome = "Outcome"
        case creationDate = "CreationDate"
        case lastStateChangeDate = "LastStateChangeDate"
        case affidavits = "Affidavits"
        case attachments = "Attachments"
        case acceptOrRejectComments = "AcceptOrRejectComments"
        case timeToLive = "TimeToLive"
        case onlineRetentionPeriod = "OnlineRetentionPeriod"
        case notaryRetentionPeriod = "NotaryRetentionPeriod"
        case notaryProfile = "NotaryProfile"
        case sourceChannel = "SourceChannel"
        case allowRefusal = "AllowRefusal"
        case affidavitKinds = "AffidavitKinds"
    }
}

struct ContactInfo: Codable {
    let legalName: String?
    let emailAddress: String
    
    enum CodingKeys: String, CodingKey {
        case legalName = "LegalName"
        case emailAddress = "EmailAddress"
    }
}

struct APIAffidavit: Codable {
    let uniqueId: String
    let date: String
    let evidenceUniqueId: String
    let description: String
    let bytes: String?
    let kind: String
    
    enum CodingKeys: String, CodingKey {
        case uniqueId = "UniqueId"
        case date = "Date"
        case evidenceUniqueId = "EvidenceUniqueId"
        case description = "Description"
        case bytes = "Bytes"
        case kind = "Kind"
    }
}

struct APIAttachment: Codable {
    let uniqueId: String
    let date: String
    let evidenceUniqueId: String
    let displayName: String
    let fileName: String
    let mimeType: String
    let data: String?
    let hash: String
    
    enum CodingKeys: String, CodingKey {
        case uniqueId = "UniqueId"
        case date = "Date"
        case evidenceUniqueId = "EvidenceUniqueId"
        case displayName = "DisplayName"
        case fileName = "FileName"
        case mimeType = "MimeType"
        case data = "Data"
        case hash = "Hash"
    }
}
