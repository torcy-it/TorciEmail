//
//  EviMail.swift
//  CertfiedEmail
//
//  Modelli DTO di risposta API per EviMail, allegati e affidavits.
//  Questi tipi rappresentano il payload remoto prima del mapping nel dominio UI.
//

import Foundation

struct EviMail: Codable, Hashable {
    let uniqueId: String?
    let issuer: Contact?
    let recipient: Contact
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
    let rejectedOn: String?
    let expiredOn: String?
    let failedOn: String?
    
    let outcome: String?
    let timeToLive: Int?
    let costCentre: String?
    let onlineRetentionPeriod: Int?
    let sourceChannel: String?
    
    let carbonCopy: [CarbonCopy]?
    let affidavitKinds: [String]?
    
    let affidavits: [Affidavit]?
    let attachments: [EviMailAttachment]?
    let acceptOrRejectComments: String?
    
    let xmissionResult: Bool?
    let xmissionSummary: String?
    let from: String?
    let customLayoutLogoUrl: String?
    let siteName: String?
    
    // Additional fields for complete modal support
    let language: String?
    let evidenceAccessControlMethod: String?
    let evidenceAccessControlChallenge: String?
    let acceptReasons: [String]?
    let rejectReasons: [String]?
    let commitmentOptions: [String]?
    let deliveryMode: String?
    
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
        case rejectedOn
        case expiredOn
        case failedOn
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
        case language
        case evidenceAccessControlMethod
        case evidenceAccessControlChallenge
        case acceptReasons
        case rejectReasons
        case commitmentOptions
        case deliveryMode
    }
}

// MARK: - Contact

struct CarbonCopy: Codable, Hashable {
    let name: String?
    let emailAddress: String
}

struct Contact: Codable, Hashable {
    let legalName: String?
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
    let bytes: String?
    
    /// Timestamp parsato da stringa ISO8601 (con o senza fractional seconds).
    var timestamp: Date? {
        guard let date = date else { return nil }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let parsedDate = formatter.date(from: date) {
            return parsedDate
        }
        
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: date)
    }
    
    var id: String { uniqueId }
    
    enum CodingKeys: String, CodingKey {
        case uniqueId
        case date
        case evidenceUniqueId
        case partyUniqueId
        case description
        case kind
        case additionalData
        case bytes
        case bytesLegacy = "Bytes"
        case blob
        case blobLegacy = "Blob"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        uniqueId = try container.decode(String.self, forKey: .uniqueId)
        date = try container.decodeIfPresent(String.self, forKey: .date)
        evidenceUniqueId = try container.decodeIfPresent(String.self, forKey: .evidenceUniqueId)
        partyUniqueId = try container.decodeIfPresent(String.self, forKey: .partyUniqueId)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        kind = try container.decode(String.self, forKey: .kind)
        additionalData = try container.decodeIfPresent([String: String].self, forKey: .additionalData)
        
        let bytesFromContainer = try container.decodeIfPresent(String.self, forKey: .bytes)
            ?? container.decodeIfPresent(String.self, forKey: .bytesLegacy)
            ?? container.decodeIfPresent(String.self, forKey: .blob)
            ?? container.decodeIfPresent(String.self, forKey: .blobLegacy)
        
        let bytesFromAdditionalData = additionalData?["bytes"]
            ?? additionalData?["Bytes"]
            ?? additionalData?["blob"]
            ?? additionalData?["Blob"]
        
        bytes = bytesFromContainer ?? bytesFromAdditionalData
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uniqueId, forKey: .uniqueId)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(evidenceUniqueId, forKey: .evidenceUniqueId)
        try container.encodeIfPresent(partyUniqueId, forKey: .partyUniqueId)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(kind, forKey: .kind)
        try container.encodeIfPresent(additionalData, forKey: .additionalData)
        try container.encodeIfPresent(bytes, forKey: .bytes)
    }
}

// MARK: - EviMailAttachment

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
    let data: String?
    
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
        case dataUpper = "Data"
        case dataLower = "data"
        case bytes
        case bytesLegacy = "Bytes"
        case blob
        case blobLegacy = "Blob"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        uniqueId = try container.decode(String.self, forKey: .uniqueId)
        creationDate = try container.decodeIfPresent(String.self, forKey: .creationDate)
        evidenceUniqueId = try container.decodeIfPresent(String.self, forKey: .evidenceUniqueId)
        contentId = try container.decodeIfPresent(String.self, forKey: .contentId)
        displayName = try container.decode(String.self, forKey: .displayName)
        filename = try container.decode(String.self, forKey: .filename)
        mimeType = try container.decode(String.self, forKey: .mimeType)
        contentDisposition = try container.decodeIfPresent(String.self, forKey: .contentDisposition)
        contentEncoding = try container.decodeIfPresent(String.self, forKey: .contentEncoding)
        contentLength = try container.decodeIfPresent(Int.self, forKey: .contentLength)
        hash = try container.decodeIfPresent(String.self, forKey: .hash)
        let dataFromLower = try container.decodeIfPresent(String.self, forKey: .dataLower)
        let dataFromUpper = try container.decodeIfPresent(String.self, forKey: .dataUpper)
        let dataFromBytes = try container.decodeIfPresent(String.self, forKey: .bytes)
        let dataFromBytesLegacy = try container.decodeIfPresent(String.self, forKey: .bytesLegacy)
        let dataFromBlob = try container.decodeIfPresent(String.self, forKey: .blob)
        let dataFromBlobLegacy = try container.decodeIfPresent(String.self, forKey: .blobLegacy)
        
        data = dataFromLower ?? dataFromUpper ?? dataFromBytes ?? dataFromBytesLegacy ?? dataFromBlob ?? dataFromBlobLegacy
    }
    
 
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uniqueId, forKey: .uniqueId)
        try container.encodeIfPresent(creationDate, forKey: .creationDate)
        try container.encodeIfPresent(evidenceUniqueId, forKey: .evidenceUniqueId)
        try container.encodeIfPresent(contentId, forKey: .contentId)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(filename, forKey: .filename)
        try container.encode(mimeType, forKey: .mimeType)
        try container.encodeIfPresent(contentDisposition, forKey: .contentDisposition)
        try container.encodeIfPresent(contentEncoding, forKey: .contentEncoding)
        try container.encodeIfPresent(contentLength, forKey: .contentLength)
        try container.encodeIfPresent(hash, forKey: .hash)
        try container.encodeIfPresent(data, forKey: .dataLower)
    }
}

