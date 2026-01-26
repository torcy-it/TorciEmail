//
//  EvidenceDetails.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import Foundation

// MARK: - Evidence Details
struct EvidenceDetails: Identifiable, Hashable, Codable {
    let id: UUID
    
    var universalLocator: String
    var typeOfEvidence: String
    var status: String
    var outcome: String
    var senderAddress: String
    var senderNameOrCompany: String
    var recipients: String
    var otherRecipients: String
    var sourceChannel: String
    var dateOfCreation: String
    var dateOfAdmission: String
    var sendingDate: String
    var openingDate: String
    var answeredOn: String
    var endOfTrackingIn: String
    var onlineCustodyYears: String
    var certificationLevel: String
    var affidavitsProfile: String
    var signatureAcknowledgementOfReceipt: String
    var requiresCaptcha: String
    var agreementPossibilities: String
    var commentsAllowed: String
    var accessControl: String
    var language: String
    var appearance: String
    var totalSizeWithAnnexes: String
    var contentSize: String
    
    init(
        id: UUID = UUID(),
        universalLocator: String = "",
        typeOfEvidence: String = "",
        status: String = "",
        outcome: String = "",
        senderAddress: String = "",
        senderNameOrCompany: String = "",
        recipients: String = "",
        otherRecipients: String = "",
        sourceChannel: String = "",
        dateOfCreation: String = "",
        dateOfAdmission: String = "",
        sendingDate: String = "",
        openingDate: String = "",
        answeredOn: String = "",
        endOfTrackingIn: String = "",
        onlineCustodyYears: String = "",
        certificationLevel: String = "",
        affidavitsProfile: String = "",
        signatureAcknowledgementOfReceipt: String = "",
        requiresCaptcha: String = "",
        agreementPossibilities: String = "",
        commentsAllowed: String = "",
        accessControl: String = "",
        language: String = "",
        appearance: String = "",
        totalSizeWithAnnexes: String = "",
        contentSize: String = ""
    ) {
        self.id = id
        self.universalLocator = universalLocator
        self.typeOfEvidence = typeOfEvidence
        self.status = status
        self.outcome = outcome
        self.senderAddress = senderAddress
        self.senderNameOrCompany = senderNameOrCompany
        self.recipients = recipients
        self.otherRecipients = otherRecipients
        self.sourceChannel = sourceChannel
        self.dateOfCreation = dateOfCreation
        self.dateOfAdmission = dateOfAdmission
        self.sendingDate = sendingDate
        self.openingDate = openingDate
        self.answeredOn = answeredOn
        self.endOfTrackingIn = endOfTrackingIn
        self.onlineCustodyYears = onlineCustodyYears
        self.certificationLevel = certificationLevel
        self.affidavitsProfile = affidavitsProfile
        self.signatureAcknowledgementOfReceipt = signatureAcknowledgementOfReceipt
        self.requiresCaptcha = requiresCaptcha
        self.agreementPossibilities = agreementPossibilities
        self.commentsAllowed = commentsAllowed
        self.accessControl = accessControl
        self.language = language
        self.appearance = appearance
        self.totalSizeWithAnnexes = totalSizeWithAnnexes
        self.contentSize = contentSize
    }
}