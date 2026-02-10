//
//  EmailItem.swift
//  TorciEmail
//
//  Fixed version with correct commentsAllowed type
//

import SwiftUI

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
    
    // Raw API fields
    let acceptOrRejectComments: String?
    let costCentre: String?
    let xmissionResult: Bool?
    let xmissionSummary: String?
    let outcome: String?
    let customLayoutLogoUrl: String?
    
    init(
        id: String = UUID().uuidString,
        issuer: Contact,
        recipient : Contact,
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
        acceptedDate : String? = nil,
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
        customLayoutLogoUrl: String? = nil,
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
        if period == 1 {
            return "1 year"
        }
        return "\(period) years"
    }
}

extension Contact {
    static let unknown = Contact(legalName: "Unknown", emailAddress: "Unknown@contact.it")
}

extension Contact {
    var formatted: String {
        let name = (legalName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email = (emailAddress ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

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
    var bodyPlainText: String {
        emailBody.stripHTMLTagsRough()
    }
}

// MARK: - Examples

extension EmailItem {

    // 1) Nuova / in preparazione (New)
    static var example: EmailItem {
        // Affidavit per questo esempio
        let submittedAffidavit = Affidavit(
            uniqueId: "aff-submitted-001",
            date: "2026-01-30T15:36:38.0000000+00:00",
            evidenceUniqueId: "ex-new-001",
            partyUniqueId: "party-001",
            description: "Certificate of admission of certified email",
            kind: "EviMail:Submitted",
            additionalData: [:]
        )
        
        let example2 = EmailItem(
            id: "ex-new-001",
            issuer: Contact(legalName: "Namirial", emailAddress: "torNamirial@outlook.it"),
            recipient: Contact(legalName: "Studente", emailAddress: "torci.ado@outlook.it"),
            sender: Contact(legalName: "Namirial-test-LC", emailAddress: "support@ecertia.com"),
            carbonCopy: [],
            emailObject: "Richiesta presa in carico",
            emailBody: "<p>Messaggio appena acquisito dal sistema.</p>",
            date: "30/01/26",
            status: .new,
            eventStatus: EmailEventStatus(
                sendingStatus: .waiting,
                readingStatus: .waiting,
                contentStatus: .waiting
            ),
            events: [
                EmailEvent(
                    id: UUID(),
                    affidavit: submittedAffidavit,
                    event: .preparation,
                    state: .preparation(.pending),
                    timestampUTC: Date().addingTimeInterval(-3600),
                    description: "Message submitted and certified",
                    color: .gray,
                    icon: "IconWaitEnv"
                )
            ],
            attachments: [],
            affidavits: [submittedAffidavit],
            certificationLevel: "Standard",
            sourceChannel: "Web",
            creationDate: "30/01/2026 15:36:38",
            admissionDate: nil,
            dispatchedDate: nil,
            openedDate: nil,
            repliedDate: nil,
            expirationDate: nil,
            onlineRetentionPeriod: 1,
            affidavitKinds: ["Submitted"],
            language: "English",
            aspect: "Standard Certified",
            totalSize: nil,
            contentSize: 42,
            requiresCaptcha: false,
            allowsAgreement: true,
            commentsAllowed: false,
            accessControl: nil,
            signatureNotice: "Digital signature with: Submitted",
            acceptOrRejectComments: nil,
            costCentre: "Namirial",
            xmissionResult: nil,
            xmissionSummary: nil,
            outcome: nil,
            customLayoutLogoUrl: nil
        )
        return example2
    }

    // 2) Inviata e consegnata ma non letta (Delivered)
    static var exampleDeliveredNotRead: EmailItem {
        // Affidavit per questo esempio
        let submittedAdvancedAffidavit = Affidavit(
            uniqueId: "aff-submitted-adv-002",
            date: "2026-01-30T15:36:38.0000000+00:00",
            evidenceUniqueId: "ex-delivered-002",
            partyUniqueId: "party-002",
            description: "Certificate of admission of certified email (with graphical representation)",
            kind: "EviMail:Submitted:Advanced",
            additionalData: [:]
        )
        
        let transmissionAffidavit = Affidavit(
            uniqueId: "aff-transmission-002",
            date: "2026-01-30T15:36:40.0000000+00:00",
            evidenceUniqueId: "ex-delivered-002",
            partyUniqueId: "party-002",
            description: "Certification of the result of the certified email transmission",
            kind: "EviMail:Transmission:Result",
            additionalData: [:]
        )
        
        let deliveryAffidavit = Affidavit(
            uniqueId: "aff-delivery-002",
            date: "2026-01-30T15:36:41.0000000+00:00",
            evidenceUniqueId: "ex-delivered-002",
            partyUniqueId: "party-002",
            description: "Certification of the result of the delivery of the certified email",
            kind: "EviMail:Delivery:Result",
            additionalData: [:]
        )
        
        let completeExample = EmailItem(
            id: "ex-delivered-002",
            issuer: Contact(legalName: "Namirial", emailAddress: "torNamirial@outlook.it"),
            recipient: Contact(legalName: "Studente", emailAddress: "torci.ado@outlook.it"),
            sender: Contact(legalName: "Namirial-test-LC", emailAddress: "support@ecertia.com"),
            carbonCopy: [],
            emailObject: "Consegna effettuata",
            emailBody: "<p>La mail è stata consegnata al server del destinatario.</p>",
            date: "30/01/26",
            status: .delivered,
            eventStatus: EmailEventStatus(
                sendingStatus: .sent,
                readingStatus: .waiting,
                contentStatus: .waiting
            ),
            events: [
                EmailEvent(
                    id: UUID(),
                    affidavit: submittedAdvancedAffidavit,
                    event: .preparation,
                    state: .preparation(.pending),
                    timestampUTC: Date().addingTimeInterval(-7200),
                    description: "Message submitted and certified",
                    color: .gray,
                    icon: "IconWaitEnv"
                ),
                EmailEvent(
                    id: UUID(),
                    affidavit: transmissionAffidavit,
                    event: .preparation,
                    state: .preparation(.ready),
                    timestampUTC: Date().addingTimeInterval(-7000),
                    description: "Message ready for transmission",
                    color: .tail,
                    icon: "IconWaitEnv"
                ),
                EmailEvent(
                    id: UUID(),
                    affidavit: deliveryAffidavit,
                    event: .sending,
                    state: .sending(.delivered),
                    timestampUTC: Date().addingTimeInterval(-3600),
                    description: "Successfully delivered to mailbox",
                    color: .tail,
                    icon: "IconSendEnv"
                ),
                EmailEvent(
                    id: UUID(),
                    affidavit: deliveryAffidavit,
                    event: .reading,
                    state: .reading(.waiting),
                    timestampUTC: Date().addingTimeInterval(-3599),
                    description: "Awaiting recipient to open message",
                    color: .gray,
                    icon: "IconWaitOpenEnv"
                )
            ],
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
            affidavits: [submittedAdvancedAffidavit, transmissionAffidavit, deliveryAffidavit],
            certificationLevel: "Standard",
            sourceChannel: "Api",
            creationDate: "30/01/2026 15:36:38",
            admissionDate: "30/01/2026 15:36:38",
            dispatchedDate: "30/01/2026 15:36:41",
            openedDate: nil,
            repliedDate: nil,
            expirationDate: nil,
            onlineRetentionPeriod: 1,
            affidavitKinds: ["Submitted", "SubmittedAdvanced", "DeliveryResult"],
            language: "English",
            aspect: "Standard Certified",
            totalSize: 13264,
            contentSize: 120,
            requiresCaptcha: false,
            allowsAgreement: true,
            commentsAllowed: false,
            accessControl: nil,
            signatureNotice: "Digital signature with: Submitted, SubmittedAdvanced, DeliveryResult",
            acceptOrRejectComments: nil,
            costCentre: "Namirial",
            xmissionResult: true,
            xmissionSummary: "Sent to recipient's mail server, waiting for follow-up updates.",
            outcome: nil,
            customLayoutLogoUrl: nil
        )
        return completeExample
    }

    // 3) Letta e accettata (Outcome Accepted)
    static var exampleAccepted: EmailItem {
        let submittedAdvancedAffidavit = Affidavit(
            uniqueId: "aff-submitted-adv-003",
            date: "2026-01-30T15:36:38.0000000+00:00",
            evidenceUniqueId: "ex-accepted-003",
            partyUniqueId: "party-003",
            description: "Certificate of admission of certified email (with graphical representation)",
            kind: "EviMail:Submitted:Advanced",
            additionalData: [:]
        )
        
        let transmissionAffidavit = Affidavit(
            uniqueId: "aff-transmission-003",
            date: "2026-01-30T15:36:40.0000000+00:00",
            evidenceUniqueId: "ex-accepted-003",
            partyUniqueId: "party-003",
            description: "Certification of the result of the certified email transmission",
            kind: "EviMail:Transmission:Result",
            additionalData: [:]
        )
        
        let deliveryAffidavit = Affidavit(
            uniqueId: "aff-delivery-003",
            date: "2026-01-30T15:36:41.0000000+00:00",
            evidenceUniqueId: "ex-accepted-003",
            partyUniqueId: "party-003",
            description: "Certification of the result of the delivery of the certified email",
            kind: "EviMail:Delivery:Result",
            additionalData: [:]
        )
        
        let readAffidavit = Affidavit(
            uniqueId: "aff-read-003",
            date: "2026-01-30T15:38:23.0000000+00:00",
            evidenceUniqueId: "ex-accepted-003",
            partyUniqueId: "party-003",
            description: "Certification of acknowledgement of opening/reading of message",
            kind: "EviMail:Read",
            additionalData: [:]
        )
        
        let committedAdvancedAffidavit = Affidavit(
            uniqueId: "aff-committed-adv-003",
            date: "2026-01-30T15:39:28.0000000+00:00",
            evidenceUniqueId: "ex-accepted-003",
            partyUniqueId: "party-003",
            description: "Certification of formal acceptation of the message (with graphical representation)",
            kind: "EviMail:Committed:Advanced",
            additionalData: ["outcome": "accepted"]
        )
        
        let example3 = EmailItem(
            id: "ex-accepted-003",
            issuer: Contact(legalName: "Namirial", emailAddress: "torNamirial@outlook.it"),
            recipient: Contact(legalName: "Studente", emailAddress: "torci.ado@outlook.it"),
            sender: Contact(legalName: "Namirial-test-LC", emailAddress: "support@ecertia.com"),
            carbonCopy: [
                Contact(legalName: "Adolfo", emailAddress: "torcy.ado@gmail.com")
            ],
            emailObject: "Test per verificare metadati evimail",
            emailBody: "<p>Sto eseguendo un test per verificare i metadati.</p>",
            date: "31/01/26",
            status: .closed,
            eventStatus: EmailEventStatus(
                sendingStatus: .sent,
                readingStatus: .opened,
                contentStatus: .accepted
            ),
            events: [
                EmailEvent(
                    id: UUID(),
                    affidavit: submittedAdvancedAffidavit,
                    event: .preparation,
                    state: .preparation(.pending),
                    timestampUTC: Date().addingTimeInterval(-86400),
                    description: "Message submitted and certified",
                    color: .gray,
                    icon: "IconWaitEnv"
                ),
                EmailEvent(
                    id: UUID(),
                    affidavit: transmissionAffidavit,
                    event: .preparation,
                    state: .preparation(.ready),
                    timestampUTC: Date().addingTimeInterval(-86300),
                    description: "Message ready for transmission",
                    color: .tail,
                    icon: "IconWaitEnv"
                ),
                EmailEvent(
                    id: UUID(),
                    affidavit: deliveryAffidavit,
                    event: .sending,
                    state: .sending(.delivered),
                    timestampUTC: Date().addingTimeInterval(-80000),
                    description: "Successfully delivered to mailbox",
                    color: .tail,
                    icon: "IconSendEnv"
                ),
                EmailEvent(
                    id: UUID(),
                    affidavit: readAffidavit,
                    event: .reading,
                    state: .reading(.opened),
                    timestampUTC: Date().addingTimeInterval(-70000),
                    description: "Message opened by recipient",
                    color: .lightGreen,
                    icon: "IconOpenEnv"
                ),
                EmailEvent(
                    id: UUID(),
                    affidavit: committedAdvancedAffidavit,
                    event: .decision,
                    state: .decision(.contentAccepted),
                    timestampUTC: Date().addingTimeInterval(-60000),
                    description: "Content formally accepted by recipient",
                    color: .sky,
                    icon: "IconContentAcc"
                )
            ],
            affidavits: [
                submittedAdvancedAffidavit,
                transmissionAffidavit,
                deliveryAffidavit,
                readAffidavit,
                committedAdvancedAffidavit
            ],
            certificationLevel: "Advanced",
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
            language: "English",
            aspect: "Standard Certified",
            totalSize: 13264,
            contentSize: 250,
            requiresCaptcha: false,
            allowsAgreement: true,
            commentsAllowed: true,
            accessControl: nil,
            signatureNotice: "Digital signature with: Submitted, SubmittedAdvanced, Committed, CommittedAdvanced, Closed, ClosedAdvanced, Complete, CompleteAdvanced",
            acceptOrRejectComments: "Accetta per test",
            costCentre: "Namirial",
            xmissionResult: true,
            xmissionSummary: "The system successfully sent the message...",
            outcome: "Accepted",
            customLayoutLogoUrl: nil
        )
        
        return example3
    }

    // 4) Fallita (xmissionResult = false)
    static var exampleFailed: EmailItem {
        let submittedAffidavit = Affidavit(
            uniqueId: "aff-submitted-004",
            date: "2026-01-30T10:12:00.0000000+00:00",
            evidenceUniqueId: "ex-failed-004",
            partyUniqueId: "party-004",
            description: "Certificate of admission of certified email",
            kind: "EviMail:Submitted",
            additionalData: [:]
        )
        
        let failedAffidavit = Affidavit(
            uniqueId: "aff-failed-004",
            date: "2026-01-30T10:12:05.0000000+00:00",
            evidenceUniqueId: "ex-failed-004",
            partyUniqueId: "party-004",
            description: "Certification of message processing failure",
            kind: "EviMail:Failed",
            additionalData: ["error": "Unrecoverable error: delivery failed"]
        )
        
        let example4 = EmailItem(
            id: "ex-failed-004",
            issuer: Contact(legalName: "Namirial", emailAddress: "torNamirial@outlook.it"),
            recipient: Contact(legalName: "Studente", emailAddress: "torci.ado@outlook.it"),
            sender: Contact(legalName: "Namirial-test-LC", emailAddress: "support@ecertia.com"),
            carbonCopy: [],
            emailObject: "Invio non riuscito",
            emailBody: "<p>Errore di trasmissione.</p>",
            date: "30/01/26",
            status: .failed,
            eventStatus: EmailEventStatus(
                sendingStatus: .failed,
                readingStatus: .waiting,
                contentStatus: .waiting
            ),
            events: [
                EmailEvent(
                    id: UUID(),
                    affidavit: submittedAffidavit,
                    event: .preparation,
                    state: .preparation(.pending),
                    timestampUTC: Date().addingTimeInterval(-7200),
                    description: "Message submitted and certified",
                    color: .gray,
                    icon: "IconWaitEnv"
                ),
                EmailEvent(
                    id: UUID(),
                    affidavit: failedAffidavit,
                    event: .sending,
                    state: .sending(.failed),
                    timestampUTC: Date().addingTimeInterval(-3600),
                    description: "Transmission failed: Unrecoverable error: delivery failed.",
                    color: .lightRed,
                    icon: "IconRejectedEnv"
                )
            ],
            attachments: [],
            affidavits: [submittedAffidavit, failedAffidavit],
            certificationLevel: "Standard",
            sourceChannel: "Api",
            creationDate: "30/01/2026 10:12:00",
            admissionDate: "30/01/2026 10:12:05",
            dispatchedDate: nil,
            openedDate: nil,
            repliedDate: nil,
            expirationDate: nil,
            onlineRetentionPeriod: 1,
            affidavitKinds: ["Submitted", "Failed"],
            language: "English",
            aspect: "Standard Certified",
            totalSize: nil,
            contentSize: 90,
            requiresCaptcha: false,
            allowsAgreement: true,
            commentsAllowed: false,
            accessControl: nil,
            signatureNotice: "Digital signature with: Submitted, Failed",
            acceptOrRejectComments: nil,
            costCentre: "Namirial",
            xmissionResult: false,
            xmissionSummary: "Unrecoverable error: delivery failed.",
            outcome: nil,
            customLayoutLogoUrl: nil
        )
        return example4
    }

    // 5) Scaduta (Expired)
    static var exampleExpired: EmailItem {
        let submittedAffidavit = Affidavit(
            uniqueId: "aff-submitted-005",
            date: "2026-01-30T09:00:00.0000000+00:00",
            evidenceUniqueId: "ex-expired-005",
            partyUniqueId: "party-005",
            description: "Certificate of admission of certified email",
            kind: "EviMail:Submitted",
            additionalData: [:]
        )
        
        let deliveryAffidavit = Affidavit(
            uniqueId: "aff-delivery-005",
            date: "2026-01-30T09:00:10.0000000+00:00",
            evidenceUniqueId: "ex-expired-005",
            partyUniqueId: "party-005",
            description: "Certification of the result of the delivery of the certified email",
            kind: "EviMail:Delivery:Result",
            additionalData: [:]
        )
        
        let closedAffidavit = Affidavit(
            uniqueId: "aff-closed-005",
            date: "2026-01-31T09:25:00.0000000+00:00",
            evidenceUniqueId: "ex-expired-005",
            partyUniqueId: "party-005",
            description: "Certification of completion of follow-up",
            kind: "EviMail:Closed",
            additionalData: [:]
        )
        
        let completeAffidavit = Affidavit(
            uniqueId: "aff-complete-005",
            date: "2026-01-31T09:25:00.0000000+00:00",
            evidenceUniqueId: "ex-expired-005",
            partyUniqueId: "party-005",
            description: "Certification of the certified email file",
            kind: "EviMail:Complete",
            additionalData: [:]
        )
        
        let example1 = EmailItem(
            id: "ex-expired-005",
            issuer: Contact(legalName: "Namirial", emailAddress: "torNamirial@outlook.it"),
            recipient: Contact(legalName: "Studente", emailAddress: "torci.ado@outlook.it"),
            sender: Contact(legalName: "Namirial-test-LC", emailAddress: "support@ecertia.com"),
            carbonCopy: [],
            emailObject: "Richiesta scaduta",
            emailBody: "<p>La richiesta non è stata accettata entro i tempi.</p>",
            date: "31/01/26",
            status: .expired,
            eventStatus: EmailEventStatus(
                sendingStatus: .sent,
                readingStatus: .waiting,
                contentStatus: .rejected
            ),
            events: [
                EmailEvent(
                    id: UUID(),
                    affidavit: submittedAffidavit,
                    event: .preparation,
                    state: .preparation(.pending),
                    timestampUTC: Date().addingTimeInterval(-172800),
                    description: "Message submitted and certified",
                    color: .gray,
                    icon: "IconWaitEnv"
                ),
                EmailEvent(
                    id: UUID(),
                    affidavit: deliveryAffidavit,
                    event: .sending,
                    state: .sending(.delivered),
                    timestampUTC: Date().addingTimeInterval(-86400),
                    description: "Successfully delivered to mailbox",
                    color: .tail,
                    icon: "IconSendEnv"
                ),
                EmailEvent(
                    id: UUID(),
                    affidavit: completeAffidavit,
                    event: .closing,
                    state: .closing(.closed),
                    timestampUTC: Date().addingTimeInterval(-3600),
                    description: "Certificate validity period expired",
                    color: .gray,
                    icon: "IconWaitEnv"
                )
            ],
            attachments: [],
            affidavits: [
                submittedAffidavit,
                deliveryAffidavit,
                closedAffidavit,
                completeAffidavit
            ],
            certificationLevel: "Standard",
            sourceChannel: "Web",
            creationDate: "30/01/2026 09:00:00",
            admissionDate: "30/01/2026 09:00:02",
            dispatchedDate: "30/01/2026 09:00:10",
            openedDate: nil,
            repliedDate: nil,
            expirationDate: "31/01/2026 09:25:00",
            onlineRetentionPeriod: 1,
            affidavitKinds: ["Submitted", "Closed", "Complete"],
            language: "English",
            aspect: "Standard Certified",
            totalSize: nil,
            contentSize: 140,
            requiresCaptcha: false,
            allowsAgreement: true,
            commentsAllowed: false,
            accessControl: nil,
            signatureNotice: "Digital signature with: Submitted, Closed, Complete",
            acceptOrRejectComments: nil,
            costCentre: "Namirial",
            xmissionResult: true,
            xmissionSummary: "Delivered; tracking closed after TTL expired.",
            outcome: "Expired",
            customLayoutLogoUrl: nil
        )
        
        return example1
    }
}

