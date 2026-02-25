//
//  EviMailSubmitRequest.swift
//  TorciEmail
//
//  DTO request/response per submit EviMail.
//  Definisce payload completo inviato all'endpoint `/evimails/submit`.
//

import Foundation

// MARK: - Submit Request

/// Payload principale submit email certificata.
struct EviMailSubmitRequest: Codable {
    let subject: String
    let body: String
    let issuerName: String
    let replyTo: String?
    let disableSenderHeader: Bool?
    let recipient: SubmitRecipient
    let carbonCopy: [SubmitCarbonCopy]?
    let options: SubmitOptions?
    let attachments: [SubmitAttachment]?
    
    enum CodingKeys: String, CodingKey {
        case subject = "Subject"
        case body = "Body"
        case issuerName = "IssuerName"
        case replyTo = "ReplyTo"
        case disableSenderHeader = "DisableSenderHeader"
        case recipient = "Recipient"
        case carbonCopy = "CarbonCopy"
        case options = "Options"
        case attachments = "Attachments"
    }
}

// MARK: - Submit Recipient

/// Destinatario principale del submit.
struct SubmitRecipient: Codable {
    let legalName: String?
    let emailAddress: String
    
    enum CodingKeys: String, CodingKey {
        case legalName = "LegalName"
        case emailAddress = "EmailAddress"
    }
}

// MARK: - Submit Carbon Copy

/// Destinatario in copia conoscenza.
struct SubmitCarbonCopy: Codable {
    let name: String
    let emailAddress: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case emailAddress = "EmailAddress"
    }
}

// MARK: - Submit Attachment

/// Allegato inviato in submit (base64 + metadati MIME).
struct SubmitAttachment: Codable {
    let displayName: String
    let fileName: String
    let data: String
    let mimeType: String
    let contentId: String?
    let contentDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case displayName = "DisplayName"
        case fileName = "FileName"
        case data = "Data"
        case mimeType = "MimeType"
        case contentId = "ContentId"
        case contentDescription = "ContentDescription"
    }
}

// MARK: - Submit Options

/// Opzioni avanzate di certificazione e workflow.
struct SubmitOptions: Codable {
    let costCentre: String?
    let certificationLevel: String?
    let affidavitsOnDemandEnabled: Bool?
    let timeToLive: Int?
    let hideBanners: Bool?
    let language: String?
    let affidavitLanguage: String?
    let evidenceAccessControlMethod: String?
    let evidenceAccessControlChallenge: String?
    let evidenceAccessControlChallengeResponse: String?
    let onlineRetentionPeriod: Int?
    let deliveryMode: String?
    let whatsAppPinPolicy: String?
    let commitmentOptions: String?
    let commitmentCommentsAllowed: Bool?
    let rejectReasons: [String]?
    let acceptReasons: [String]?
    let requireRejectReason: Bool?
    let requireAcceptReason: Bool?
    let pushNotificationUrl: String?
    let pushNotificationFilter: [String]?
    let affidavitKinds: [String]?
    let customLayoutLogoUrl: String?
    let pushNotificationExtraData: String?
    
    enum CodingKeys: String, CodingKey {
        case costCentre = "CostCentre"
        case certificationLevel = "CertificationLevel"
        case affidavitsOnDemandEnabled = "AffidavitsOnDemandEnabled"
        case timeToLive = "TimeToLive"
        case hideBanners = "HideBanners"
        case language = "Language"
        case affidavitLanguage = "AffidavitLanguage"
        case evidenceAccessControlMethod = "EvidenceAccessControlMethod"
        case evidenceAccessControlChallenge = "EvidenceAccessControlChallenge"
        case evidenceAccessControlChallengeResponse = "EvidenceAccessControlChallengeResponse"
        case onlineRetentionPeriod = "OnlineRetentionPeriod"
        case deliveryMode = "DeliveryMode"
        case whatsAppPinPolicy = "WhatsAppPinPolicy"
        case commitmentOptions = "CommitmentOptions"
        case commitmentCommentsAllowed = "CommitmentCommentsAllowed"
        case rejectReasons = "RejectReasons"
        case acceptReasons = "AcceptReasons"
        case requireRejectReason = "RequireRejectReason"
        case requireAcceptReason = "RequireAcceptReason"
        case pushNotificationUrl = "PushNotificationUrl"
        case pushNotificationFilter = "PushNotificationFilter"
        case affidavitKinds = "AffidavitKinds"
        case customLayoutLogoUrl = "CustomLayoutLogoUrl"
        case pushNotificationExtraData = "PushNotificationExtraData"
    }
}

// MARK: - Submit Response

/// Risposta submit con identificativo EviMail creato.
struct EviMailSubmitResponse: Codable {
    let eviId: String
    
    enum CodingKeys: String, CodingKey {
        case eviId
    }
}
