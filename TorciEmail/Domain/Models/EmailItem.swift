//
//  EmailItem.swift
//  TorciEmail
//
//  Modello di dominio principale usato dalla UI mailbox e dettagli email.
//  Contiene metadati, stato, eventi, allegati e certificati.
//

import SwiftUI

/// Entita di dominio che rappresenta una EviMail normalizzata per il client.
struct EmailItem: Identifiable, Hashable {
    let id: String
    let issuer: Contact
    let recipient: Contact
    let sender: Contact
    let carbonCopy: [Contact]
    
    let emailObject: String
    let emailBody: String
    let date: String
    let status: EmailStatus
    let eventStatus: EmailEventStatus
    let events: [EmailEvent]
    
    let attachments: [EmailAttachment]
    let affidavits: [Affidavit]
    
    // Campi di dettaglio esteso
    let certificationLevel: String?
    let sourceChannel: String?
    let creationDate: String?
    let admissionDate: String?
    let dispatchedDate: String?
    let openedDate: String?
    let repliedDate: String?
    let acceptedDate: String?
    let rejectedDate: String?
    let expirationDate: String?
    let failedDate: String?
    let onlineRetentionPeriod: Int?
    let affidavitKinds: [String]
    let language: String
    let aspect: String
    let totalSize: Int?
    let contentSize: Int?
    let requiresCaptcha: Bool
    let allowsAgreement: Bool
    let commentsAllowed: Bool
    let accessControl: String?
    let signatureNotice: String?
    
    // Campi raw API utili alla UI avanzata
    let acceptOrRejectComments: String?
    let costCentre: String?
    let xmissionResult: Bool?
    let xmissionSummary: String?
    let outcome: String?
    let customLayoutLogoUrl: String?
    
    init(
        id: String = UUID().uuidString,
        issuer: Contact,
        recipient: Contact,
        sender: Contact,
        carbonCopy: [Contact] = [],
        emailObject: String,
        emailBody: String,
        date: String,
        status: EmailStatus,
        eventStatus: EmailEventStatus,
        events: [EmailEvent] = [],
        attachments: [EmailAttachment] = [],
        affidavits: [Affidavit] = [],
        certificationLevel: String? = nil,
        sourceChannel: String? = nil,
        creationDate: String? = nil,
        admissionDate: String? = nil,
        dispatchedDate: String? = nil,
        openedDate: String? = nil,
        repliedDate: String? = nil,
        acceptedDate: String? = nil,
        rejectedDate: String? = nil,
        expirationDate: String? = nil,
        failedDate: String? = nil,
        onlineRetentionPeriod: Int? = nil,
        affidavitKinds: [String] = [],
        language: String = "English",
        aspect: String = "Standard Certified",
        totalSize: Int? = nil,
        contentSize: Int? = nil,
        requiresCaptcha: Bool = false,
        allowsAgreement: Bool = true,
        commentsAllowed: Bool = false,
        accessControl: String? = nil,
        signatureNotice: String? = nil,
        acceptOrRejectComments: String? = nil,
        costCentre: String? = nil,
        xmissionResult: Bool? = nil,
        xmissionSummary: String? = nil,
        outcome: String? = nil,
        customLayoutLogoUrl: String? = nil
    ) {
        self.id = id
        self.issuer = issuer
        self.recipient = recipient
        self.sender = sender
        self.carbonCopy = carbonCopy
        self.emailObject = emailObject
        self.emailBody = emailBody
        self.date = date
        self.status = status
        self.eventStatus = eventStatus
        self.events = events
        self.attachments = attachments
        self.affidavits = affidavits
        self.certificationLevel = certificationLevel
        self.sourceChannel = sourceChannel
        self.creationDate = creationDate
        self.admissionDate = admissionDate
        self.dispatchedDate = dispatchedDate
        self.openedDate = openedDate
        self.repliedDate = repliedDate
        self.acceptedDate = acceptedDate
        self.rejectedDate = rejectedDate
        self.expirationDate = expirationDate
        self.failedDate = failedDate
        self.onlineRetentionPeriod = onlineRetentionPeriod
        self.affidavitKinds = affidavitKinds
        self.language = language
        self.aspect = aspect
        self.totalSize = totalSize
        self.contentSize = contentSize
        self.requiresCaptcha = requiresCaptcha
        self.allowsAgreement = allowsAgreement
        self.commentsAllowed = commentsAllowed
        self.accessControl = accessControl
        self.signatureNotice = signatureNotice
        self.acceptOrRejectComments = acceptOrRejectComments
        self.costCentre = costCentre
        self.xmissionResult = xmissionResult
        self.xmissionSummary = xmissionSummary
        self.outcome = outcome
        self.customLayoutLogoUrl = customLayoutLogoUrl
    }
    
    // MARK: - Computed Properties
    
    var lastEventDate: Date? {
        events.map { $0.timestampUTC }.max()
    }
    
    var attachmentCount: Int {
        attachments.count
    }
    
    var hasAttachments: Bool {
        !attachments.isEmpty
    }
    
    var affidavitCount: Int {
        affidavits.count
    }
    
    var affidavitKindsFormatted: String {
        guard !affidavitKinds.isEmpty else { return "-" }
        return affidavitKinds.joined(separator: ", ")
    }
    
    var certificationLevelGet: String {
        if let level = certificationLevel, !level.isEmpty {
            return level
        }
        return affidavitKinds.contains { $0.localizedCaseInsensitiveContains("advanced") } ? "Advanced" : "Standard"
    }
    
    var totalSizeFormatted: String {
        guard let size = totalSize else { return "-" }
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
    
    var contentSizeFormatted: String {
        guard let size = contentSize else { return "-" }
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
    
    var retentionPeriodFormatted: String {
        guard let period = onlineRetentionPeriod else { return "Not specified" }
        return period == 1 ? "1 year" : "\(period) years"
    }
}

extension Contact {
    static let unknown = Contact(legalName: "Unknown", emailAddress: "Unknown@contact.it")
}

extension Contact {
    var formatted: String {
        let name = (legalName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if name.isEmpty && email.isEmpty { return "-" }
        if name.isEmpty { return "<\(email)>" }
        if email.isEmpty { return name }
        return "\(name) <\(email)>"
    }
}

extension Array where Element == Contact {
    var formatted: String {
        let parts = self.map(\.formatted).filter { $0 != "-" }
        return parts.isEmpty ? "-" : parts.joined(separator: ", ")
    }
}

extension String {
    /// Rimuove i principali tag HTML e rende il testo leggibile in plain text.
    func stripHTMLTagsRough() -> String {
        self
            .replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "<br/>", with: "\n")
            .replacingOccurrences(of: "<br />", with: "\n")
            .replacingOccurrences(of: "</p>", with: "\n\n")
            .replacingOccurrences(of: "<p>", with: "")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension EmailItem {
    /// Corpo email convertito in testo semplice per la visualizzazione in UI.
    var bodyPlainText: String {
        emailBody.stripHTMLTagsRough()
    }
}
