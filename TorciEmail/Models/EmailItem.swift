//
//  EmailItem.swift
//  TorciEmail
//

import SwiftUI

struct EmailItem: Identifiable, Hashable {
    let id: String
    let senderName: String
    let senderEmail: String
    let recipientName: String
    let recipientEmail: String
    let carbonCopy: [CarbonCopyRecipient]
    
    let emailObject: String
    let emailDescription: String
    let date: String
    let status: EmailStatus
    
    // 3 stati fissi per le icone nella lista
    let eventStatus: EmailEventStatus
    
    // Array completo eventi per timeline dettagliata
    let events: [EmailEvent]
    
  
    let attachments: [EmailAttachment]
    
    let affidavits: [Affidavit]
    
    // CAMPI PER I DETTAGLI
    let certificationLevel: String?
    let sourceChannel: String?
    let creationDate: String?
    let admissionDate: String?
    let dispatchedDate: String?
    let openedDate: String?
    let repliedDate: String?
    let expirationDate: String?
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
    
  
    let acceptOrRejectComments: String?
    let costCentre: String?
    let xmissionResult: Bool?
    let xmissionSummary: String?
    
    init(
        id: String = UUID().uuidString,
        senderName: String,
        senderEmail: String,
        recipientName: String,
        recipientEmail: String,
        carbonCopy: [CarbonCopyRecipient] = [],
        emailObject: String,
        emailDescription: String,
        date: String,
        status: EmailStatus,
        eventStatus: EmailEventStatus,
        events: [EmailEvent] = [],
        attachments: [EmailAttachment] = [],
        affidavits: [Affidavit] = [],
        certificationLevel: String? =  nil,
        sourceChannel: String? = nil,
        creationDate: String? = nil,
        admissionDate: String? = nil,
        dispatchedDate: String? = nil,
        openedDate: String? = nil,
        repliedDate: String? = nil,
        expirationDate: String? = nil,
        onlineRetentionPeriod: Int? = nil,
        affidavitKinds: [String] = [],
        language: String = "it",
        aspect: String = "Certificato",
        totalSize: Int? = nil,
        contentSize: Int? = nil,
        requiresCaptcha: Bool = false,
        allowsAgreement: Bool = true,
        commentsAllowed: Bool = true,
        accessControl: String? = nil,
        signatureNotice: String? = nil,
        acceptOrRejectComments: String? = nil,
        costCentre: String? = nil,
        xmissionResult: Bool? = nil,
        xmissionSummary: String? = nil
    ) {
        self.id = id
        self.senderName = senderName
        self.senderEmail = senderEmail
        self.recipientName = recipientName
        self.recipientEmail = recipientEmail
        self.carbonCopy = carbonCopy
        self.emailObject = emailObject
        self.emailDescription = emailDescription
        self.date = date
        self.status = status
        self.certificationLevel = certificationLevel
        self.eventStatus = eventStatus
        self.events = events
        self.attachments = attachments
        self.affidavits = affidavits
        self.sourceChannel = sourceChannel
        self.creationDate = creationDate
        self.admissionDate = admissionDate
        self.dispatchedDate = dispatchedDate
        self.openedDate = openedDate
        self.repliedDate = repliedDate
        self.expirationDate = expirationDate
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
    }
    
    
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
    
    var carbonCopyFormatted: String {
        guard !carbonCopy.isEmpty else { return "-" }
        return carbonCopy.map { "\($0.name) <\($0.emailAddress)>" }.joined(separator: ", ")
    }
    
    var affidavitKindsFormatted: String {
        guard !affidavitKinds.isEmpty else { return "-" }
        return affidavitKinds.joined(separator: ", ")
    }
    
    var certificationLevelGet: String {
        (certificationLevel?.isEmpty == false) ? certificationLevel! :
        (affidavitKinds.contains { $0.localizedCaseInsensitiveContains("advanced") } ? "Advanced" : "Standard")
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
        guard let period = onlineRetentionPeriod else { return "-" }
        return "\(period) anno\(period == 1 ? "" : "i")"
    }
}


extension EmailItem {

    // 1) Nuova / in preparazione (New)
    static var example: EmailItem {
        EmailItem(
            id: "ex-new-001",
            senderName: "Namirial-test-LC",
            senderEmail: "support@ecertia.com",
            recipientName: "Studente",
            recipientEmail: "adolfo <torci.ado@outlook.it>",
            carbonCopy: [],
            emailObject: "Richiesta presa in carico",
            emailDescription: "<p>Messaggio appena acquisito dal sistema.</p>",
            date: "30/01/26",
            status: .new,
            eventStatus: EmailEventStatus(
                sendingStatus: .waiting,
                readingStatus: .waiting,
                contentStatus: .waiting
            ),
            events: [],
            attachments: [],
            affidavits: [],
            sourceChannel: "Web",
            creationDate: "30/01/2026 15:36:38",
            admissionDate: nil,
            dispatchedDate: nil,
            openedDate: nil,
            repliedDate: nil,
            expirationDate: nil,
            onlineRetentionPeriod: 1,
            affidavitKinds: [],
            language: "en",
            aspect: "Certificato",
            totalSize: nil,
            contentSize: 42,
            requiresCaptcha: false,
            allowsAgreement: true,
            commentsAllowed: true,
            accessControl: nil,
            signatureNotice: nil,
            acceptOrRejectComments: nil,
            costCentre: "Namirial",
            xmissionResult: nil,
            xmissionSummary: nil
        )
    }

    // 2) Inviata e consegnata ma non letta (Delivered)
    static var exampleDeliveredNotRead: EmailItem {
        EmailItem(
            id: "ex-delivered-002",
            senderName: "Namirial-test-LC",
            senderEmail: "support@ecertia.com",
            recipientName: "Mario Rossi",
            recipientEmail: "mario.rossi@example.com",
            carbonCopy: [],
            emailObject: "Consegna effettuata",
            emailDescription: "<p>La mail è stata consegnata al server del destinatario.</p>",
            date: "30/01/26",
            status: .delivered,
            eventStatus: EmailEventStatus(
                sendingStatus: .sent,
                readingStatus: .waiting,
                contentStatus: .waiting
            ),
            events: [],
            attachments: [
                EmailAttachment(
                    id: "att-001",
                    name: "contratto.pdf",
                    filename: "contratto.pdf",
                    size: 13264,
                    mimeType: "application/pdf",
                    hash: "SHA256:xxx",
                    kind: .pdf
                )
            ],
            affidavits: [],
            sourceChannel: "Api",
            creationDate: "30/01/2026 15:36:38",
            admissionDate: "30/01/2026 15:36:38",
            dispatchedDate: "30/01/2026 15:36:41",
            openedDate: nil,
            repliedDate: nil,
            expirationDate: nil,
            onlineRetentionPeriod: 1,
            affidavitKinds: ["Submitted", "SubmittedAdvanced", "DeliveryResult"],
            language: "en",
            aspect: "Certificato",
            totalSize: 13264,
            contentSize: 120,
            requiresCaptcha: false,
            allowsAgreement: true,
            commentsAllowed: true,
            accessControl: nil,
            signatureNotice: nil,
            acceptOrRejectComments: nil,
            costCentre: "Namirial",
            xmissionResult: true,
            xmissionSummary: "Sent to recipient’s mail server, waiting for follow-up updates."
        )
    }

    // 3) Letta e accettata (Outcome Accepted / acceptedOn valorizzato)
    static var exampleAccepted: EmailItem {
        EmailItem(
            id: "ex-accepted-003",
            senderName: "Namirial-test-LC",
            senderEmail: "support@ecertia.com",
            recipientName: "Studente",
            recipientEmail: "adolfo <torci.ado@outlook.it>",
            carbonCopy: [
                CarbonCopyRecipient(name: "adolfo", emailAddress: "torcy.ado@gmail.com")
            ],
            emailObject: "Test Per verificare metadati evimail",
            emailDescription: "<p>Sto eseguendo un test per verificare i metadati.</p>",
            date: "31/01/26",
            status: .closed,
            eventStatus: EmailEventStatus(
                sendingStatus: .sent,
                readingStatus: .opened,
                contentStatus: .accepted
            ),
            events: [],
            attachments: [
                EmailAttachment(
                    id: "019c0f8c994d4b8daedd98a0b61615bf",
                    name: "pdf-sample_0.pdf",
                    filename: "pdf-sample_0.pdf",
                    size: 13264,
                    mimeType: "application/pdf",
                    hash: "SHA256:3df79d34abbca99308e79cb94461c1893582604d68329a41fd4bec1885e6adb4",
                    kind: .pdf
                )
            ],
            affidavits: [],
            sourceChannel: "Web",
            creationDate: "30/01/2026 15:36:38",
            admissionDate: "30/01/2026 15:36:38",
            dispatchedDate: "30/01/2026 15:36:41",
            openedDate: "30/01/2026 15:38:23",
            repliedDate: "30/01/2026 15:39:28",
            expirationDate: "31/01/2026 16:36:45",
            onlineRetentionPeriod: 1,
            affidavitKinds: [
                "Submitted", "SubmittedAdvanced",
                "Committed", "CommittedAdvanced",
                "Closed", "ClosedAdvanced",
                "Complete", "CompleteAdvanced"
            ],
            language: "en",
            aspect: "Certificato",
            totalSize: 13264,
            contentSize: 250,
            requiresCaptcha: false,
            allowsAgreement: true,
            commentsAllowed: true,
            accessControl: nil,
            signatureNotice: nil,
            acceptOrRejectComments: "Accetta per test",
            costCentre: "Namirial",
            xmissionResult: true,
            xmissionSummary: "The system successfully sent the message..."
        )
    }

    // 4) Fallita (xmissionResult = false)
    static var exampleFailed: EmailItem {
        EmailItem(
            id: "ex-failed-004",
            senderName: "Namirial-test-LC",
            senderEmail: "support@ecertia.com",
            recipientName: "Destinatario",
            recipientEmail: "destinatario@example.com",
            carbonCopy: [],
            emailObject: "Invio non riuscito",
            emailDescription: "<p>Errore di trasmissione.</p>",
            date: "30/01/26",
            status: .failed,
            eventStatus: EmailEventStatus(
                sendingStatus: .failed,
                readingStatus: .waiting,
                contentStatus: .waiting
            ),
            events: [],
            attachments: [],
            affidavits: [],
            sourceChannel: "Api",
            creationDate: "30/01/2026 10:12:00",
            admissionDate: "30/01/2026 10:12:05",
            dispatchedDate: nil,
            openedDate: nil,
            repliedDate: nil,
            expirationDate: nil,
            onlineRetentionPeriod: 1,
            affidavitKinds: ["Submitted", "Failed"],
            language: "en",
            aspect: "Certificato",
            totalSize: nil,
            contentSize: 90,
            requiresCaptcha: false,
            allowsAgreement: true,
            commentsAllowed: true,
            accessControl: nil,
            signatureNotice: nil,
            acceptOrRejectComments: nil,
            costCentre: "Namirial",
            xmissionResult: false,
            xmissionSummary: "Unrecoverable error: delivery failed."
        )
    }

    // 5) Scaduta (Expired)
    static var exampleExpired: EmailItem {
        EmailItem(
            id: "ex-expired-005",
            senderName: "Namirial-test-LC",
            senderEmail: "support@ecertia.com",
            recipientName: "Cliente",
            recipientEmail: "cliente@example.com",
            carbonCopy: [],
            emailObject: "Richiesta scaduta",
            emailDescription: "<p>La richiesta non è stata accettata entro i tempi.</p>",
            date: "31/01/26",
            status: .expired,
            eventStatus: EmailEventStatus(
                sendingStatus: .sent,
                readingStatus: .waiting,
                contentStatus: .rejected
            ),
            events: [],
            attachments: [],
            affidavits: [],
            sourceChannel: "Web",
            creationDate: "30/01/2026 09:00:00",
            admissionDate: "30/01/2026 09:00:02",
            dispatchedDate: "30/01/2026 09:00:10",
            openedDate: nil,
            repliedDate: nil,
            expirationDate: "31/01/2026 09:25:00",
            onlineRetentionPeriod: 1,
            affidavitKinds: ["Submitted", "Closed", "Complete"],
            language: "en",
            aspect: "Certificato",
            totalSize: nil,
            contentSize: 140,
            requiresCaptcha: false,
            allowsAgreement: true,
            commentsAllowed: true,
            accessControl: nil,
            signatureNotice: nil,
            acceptOrRejectComments: nil,
            costCentre: "Namirial",
            xmissionResult: true,
            xmissionSummary: "Delivered; tracking closed after TTL expired."
        )
    }
}
