//
//  EmailItem.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
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
    
    // Array completo eventi per timeline dettagliata (futuro)
    let events: [EmailEvent]
    
    let attachments: [EmailAttachment]
    
    // NUOVI CAMPI PER I DETTAGLI
    let sourceChannel: String?
    let creationDate: String?
    let admissionDate: String?  // readyOn
    let dispatchedDate: String?
    let openedDate: String?     // readOn
    let repliedDate: String?
    let expirationDate: String? // expiredOn
    let onlineRetentionPeriod: Int?
    let certificationLevel: [String]  // affidavitKinds
    let language: String
    let aspect: String  // "Certificato" o altro
    let totalSize: Int?  // In bytes
    let contentSize: Int?  // In bytes
    let requiresCaptcha: Bool
    let allowsAgreement: Bool  // possibilità di accordo
    let commentsAllowed: Bool
    let accessControl: String?
    let signatureNotice: String?  // Firma dell'avviso di ricezione
    
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
        sourceChannel: String? = nil,
        creationDate: String? = nil,
        admissionDate: String? = nil,
        dispatchedDate: String? = nil,
        openedDate: String? = nil,
        repliedDate: String? = nil,
        expirationDate: String? = nil,
        onlineRetentionPeriod: Int? = nil,
        certificationLevel: [String] = [],
        language: String = "it",
        aspect: String = "Certificato",
        totalSize: Int? = nil,
        contentSize: Int? = nil,
        requiresCaptcha: Bool = false,
        allowsAgreement: Bool = true,
        commentsAllowed: Bool = true,
        accessControl: String? = nil,
        signatureNotice: String? = nil
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
        self.eventStatus = eventStatus
        self.events = events
        self.attachments = attachments
        self.sourceChannel = sourceChannel
        self.creationDate = creationDate
        self.admissionDate = admissionDate
        self.dispatchedDate = dispatchedDate
        self.openedDate = openedDate
        self.repliedDate = repliedDate
        self.expirationDate = expirationDate
        self.onlineRetentionPeriod = onlineRetentionPeriod
        self.certificationLevel = certificationLevel
        self.language = language
        self.aspect = aspect
        self.totalSize = totalSize
        self.contentSize = contentSize
        self.requiresCaptcha = requiresCaptcha
        self.allowsAgreement = allowsAgreement
        self.commentsAllowed = commentsAllowed
        self.accessControl = accessControl
        self.signatureNotice = signatureNotice
    }
    
    /// Restituisce la data dell'ultimo evento avvenuto
    var lastEventDate: Date? {
        events
            .map { $0.timestampUTC }
            .max()
    }
    
    /// Conta quanti allegati ci sono
    var attachmentCount: Int {
        attachments.count
    }
    
    /// Verifica se l'email ha allegati
    var hasAttachments: Bool {
        !attachments.isEmpty
    }
    
    /// Formatta i destinatari in copia
    var carbonCopyFormatted: String {
        guard !carbonCopy.isEmpty else { return "-" }
        return carbonCopy.map { "\($0.name) <\($0.emailAddress)>" }.joined(separator: ", ")
    }
    
    /// Formatta il livello di certificazione
    var certificationLevelFormatted: String {
        guard !certificationLevel.isEmpty else { return "-" }
        return certificationLevel.joined(separator: ", ")
    }
    
    /// Formatta la dimensione in formato leggibile
    var totalSizeFormatted: String {
        guard let size = totalSize else { return "-" }
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
    
    var contentSizeFormatted: String {
        guard let size = contentSize else { return "-" }
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
    
    /// Formatta il periodo di custodia
    var retentionPeriodFormatted: String {
        guard let period = onlineRetentionPeriod else { return "-" }
        return "\(period) anno\(period == 1 ? "" : "i")"
    }
}
extension EmailItem {
    static var example: EmailItem {
        // Crea alcune date di esempio
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        let creationDate = dateFormatter.date(from: "23/09/2025 08:35:01") ?? Date()
        let sentDate = creationDate.addingTimeInterval(5)
        let deliveredDate = sentDate.addingTimeInterval(10)
        let openedDate = deliveredDate.addingTimeInterval(25)
        
        // Crea eventi di esempio
        let exampleEvents: [EmailEvent] = [
            EmailEvent(
                event: .preparation,
                state: .preparation(.pending),
                timestampUTC: creationDate
            ),
            EmailEvent(
                event: .preparation,
                state: .preparation(.ready),
                timestampUTC: creationDate.addingTimeInterval(2)
            ),
            EmailEvent(
                event: .sending,
                state: .sending(.sent),
                timestampUTC: sentDate
            ),
            EmailEvent(
                event: .sending,
                state: .sending(.dispatched),
                timestampUTC: sentDate.addingTimeInterval(3)
            ),
            EmailEvent(
                event: .sending,
                state: .sending(.delivered),
                timestampUTC: deliveredDate
            ),
            EmailEvent(
                event: .reading,
                state: .reading(.opened),
                timestampUTC: openedDate
            ),
            EmailEvent(
                event: .decision,
                state: .decision(.waitingDecision),
                timestampUTC: openedDate.addingTimeInterval(1)
            )
        ]
        
        return EmailItem(
            id: "019975b63c2040c4ae74fb6c690aee63",
            senderName: "Namirial",
            senderEmail: "l.castaldo+testlc@namirial.com",
            recipientName: "luigi.castaldo+test23@icloud.com",
            recipientEmail: "luigi.castaldo+test23@icloud.com",
            carbonCopy: [],
            emailObject: "Test invio EviMail",
            emailDescription: "Corpo del messaggio inviato tramite piattaforma",
            date: "30/09/25",
            status: .closed,
            eventStatus: EmailEventStatus(
                sendingStatus: .sent,
                readingStatus: .opened,
                contentStatus: .waiting
            ),
            events: exampleEvents,  
            attachments: [],
            sourceChannel: "Web",
            creationDate: "23/09/2025 08:35:01",
            admissionDate: "23/09/2025 08:35:01",
            dispatchedDate: "23/09/2025 08:35:01",
            openedDate: "23/09/2025 08:35:26",
            repliedDate: nil,
            expirationDate: "30/09/2025 08:35:05",
            onlineRetentionPeriod: 1,
            certificationLevel: ["Complete"],
            language: "en",
            aspect: "Certified",
            totalSize: nil,
            contentSize: 52,
            requiresCaptcha: false,
            allowsAgreement: true,
            commentsAllowed: true,
            accessControl: nil,
            signatureNotice: nil
        )
    }
    
    static var completedExample: EmailItem {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        let creationDate = dateFormatter.date(from: "20/09/2025 10:00:00") ?? Date()
        let sentDate = creationDate.addingTimeInterval(5)
        let deliveredDate = sentDate.addingTimeInterval(10)
        let openedDate = deliveredDate.addingTimeInterval(300)
        let acceptedDate = openedDate.addingTimeInterval(120)
        
        let completedEvents: [EmailEvent] = [
            EmailEvent(
                event: .preparation,
                state: .preparation(.pending),
                timestampUTC: creationDate
            ),
            EmailEvent(
                event: .preparation,
                state: .preparation(.ready),
                timestampUTC: creationDate.addingTimeInterval(2)
            ),
            EmailEvent(
                event: .sending,
                state: .sending(.sent),
                timestampUTC: sentDate
            ),
            EmailEvent(
                event: .sending,
                state: .sending(.delivered),
                timestampUTC: deliveredDate
            ),
            EmailEvent(
                event: .reading,
                state: .reading(.opened),
                timestampUTC: openedDate
            ),
            EmailEvent(
                event: .decision,
                state: .decision(.contentAccepted),
                timestampUTC: acceptedDate
            )
        ]
        
        return EmailItem(
            id: "019975b63c2040c4ae74fb6c690aee64",
            senderName: "Tech Corp",
            senderEmail: "contact@techcorp.com",
            recipientName: "Mario Rossi",
            recipientEmail: "mario.rossi@example.com",
            carbonCopy: [],
            emailObject: "Contratto di consulenza",
            emailDescription: "Invio contratto per approvazione e firma",
            date: "20/09/25",
            status: .closed,
            eventStatus: EmailEventStatus(
                sendingStatus: .sent,
                readingStatus: .opened,
                contentStatus: .accepted
            ),
            events: completedEvents,
            attachments: [],
            sourceChannel: "API",
            creationDate: "20/09/2025 10:00:00",
            admissionDate: "20/09/2025 10:00:02",
            dispatchedDate: "20/09/2025 10:00:05",
            openedDate: "20/09/2025 10:05:05",
            repliedDate: "20/09/2025 10:07:05",
            expirationDate: "27/09/2025 10:00:00",
            onlineRetentionPeriod: 2,
            certificationLevel: ["Complete", "Advanced"],
            language: "it",
            aspect: "Certificato",
            totalSize: 1024,
            contentSize: 512,
            requiresCaptcha: true,
            allowsAgreement: true,
            commentsAllowed: true,
            accessControl: "Password Protected",
            signatureNotice: "Firma elettronica qualificata"
        )
    }
    
    /// ⚠️ NUOVO: Esempio con invio fallito
    static var failedExample: EmailItem {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        let creationDate = dateFormatter.date(from: "15/09/2025 14:30:00") ?? Date()
        let failedDate = creationDate.addingTimeInterval(30)
        
        let failedEvents: [EmailEvent] = [
            EmailEvent(
                event: .preparation,
                state: .preparation(.pending),
                timestampUTC: creationDate
            ),
            EmailEvent(
                event: .preparation,
                state: .preparation(.ready),
                timestampUTC: creationDate.addingTimeInterval(2)
            ),
            EmailEvent(
                event: .sending,
                state: .sending(.failed),
                timestampUTC: failedDate
            )
        ]
        
        return EmailItem(
            id: "019975b63c2040c4ae74fb6c690aee65",
            senderName: "Accounting Dept",
            senderEmail: "accounting@company.com",
            recipientName: "Invalid User",
            recipientEmail: "invalid@nonexistent-domain-xyz.com",
            carbonCopy: [],
            emailObject: "Fattura mensile",
            emailDescription: "Invio fattura per il mese corrente",
            date: "15/09/25",
            status: .failed,
            eventStatus: EmailEventStatus(
                sendingStatus: .failed,
                readingStatus: .waiting,
                contentStatus: .waiting
            ),
            events: failedEvents,
            attachments: [],
            sourceChannel: "SMTP",
            creationDate: "15/09/2025 14:30:00",
            admissionDate: "15/09/2025 14:30:02",
            dispatchedDate: nil,
            openedDate: nil,
            repliedDate: nil,
            expirationDate: nil,
            onlineRetentionPeriod: 1,
            certificationLevel: ["Basic"],
            language: "it",
            aspect: "Standard",
            totalSize: nil,
            contentSize: 200,
            requiresCaptcha: false,
            allowsAgreement: false,
            commentsAllowed: false,
            accessControl: nil,
            signatureNotice: nil
        )
    }
}
