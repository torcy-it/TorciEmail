//
//  EviMail.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//


struct EviMail: Codable {
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
}

struct Contact: Codable {
    let legalName: String?
    let emailAddress: String
}

struct CarbonCopyRecipient: Codable {
    let name: String
    let emailAddress: String
}