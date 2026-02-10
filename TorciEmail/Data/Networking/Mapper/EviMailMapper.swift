//
//  EviMailMapper.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//

import Foundation

struct EviMailMapper {
    
    /// Converte EviMail (dal server) in EmailItem (modello UI)
    static func map(_ eviMail: EviMail) -> EmailItem {
        let status = mapStatus(eviMail.state)
        let eventStatus = mapEventStatus(eviMail)
        let events = mapEvents(eviMail)
        let attachments = mapAttachments(eviMail.attachments)
        let affidavits = eviMail.affidavits ?? []
        
        // Formatta la data per la lista (usa l'ultima data disponibile)
        let displayDate = formatDate(eviMail.lastStateChangeDate)
        
        // Calcola totalSize sommando gli attachments
        let totalSize = attachments.reduce(0) { $0 + ($1.size ?? 0) }
        
        // Determina il certification level dai kind di affidavit
        let certLevel = determineCertificationLevel(eviMail.affidavitKinds)
        
        // Mappa il language dall'API
        let language = mapLanguage(eviMail.language)
        
        let emailItem = EmailItem(
            id: eviMail.uniqueId ?? UUID().uuidString,
            issuer: eviMail.issuer ?? .unknown,
            recipient: eviMail.recipient,
            sender: Contact(legalName: eviMail.siteName, emailAddress: eviMail.from ?? "Unknown"),
            carbonCopy: (eviMail.carbonCopy ?? []).map { Contact(legalName: $0.name, emailAddress: $0.emailAddress) },
            emailObject: eviMail.subject ?? "No Subject",
            emailBody: eviMail.body ?? "No Body",
            date: displayDate,
            status: status,
            eventStatus: eventStatus,
            events: events,
            attachments: attachments,
            affidavits: affidavits,
            certificationLevel: certLevel,
            sourceChannel: eviMail.sourceChannel ?? "App",
            creationDate: formatDetailDate(eviMail.creationDate),
            admissionDate: formatDetailDate(eviMail.readyOn),
            dispatchedDate: formatDetailDate(eviMail.dispatchedOn),
            openedDate: formatDetailDate(eviMail.readOn),
            repliedDate: formatDetailDate(eviMail.repliedOn),
            acceptedDate: formatDate(eviMail.acceptedOn),
            rejectedDate: formatDate(eviMail.rejectedOn),
            expirationDate: formatDetailDate(eviMail.expiredOn),
            failedDate: formatDetailDate(eviMail.failedOn),
            onlineRetentionPeriod: eviMail.onlineRetentionPeriod,
            affidavitKinds: eviMail.affidavitKinds ?? [],
            language: language,
            aspect: determineAspect(eviMail),
            totalSize: totalSize > 0 ? totalSize : nil,
            contentSize: eviMail.body?.utf8.count,
            requiresCaptcha: determineCaptchaRequirement(eviMail),
            allowsAgreement: determineAgreementAllowed(eviMail),
            commentsAllowed: !(eviMail.acceptOrRejectComments ?? "").isEmpty,
            accessControl: determineAccessControl(eviMail),
            signatureNotice: determineSignatureNotice(eviMail),
            acceptOrRejectComments: eviMail.acceptOrRejectComments,
            costCentre: eviMail.costCentre,
            xmissionResult: eviMail.xmissionResult,
            xmissionSummary: eviMail.xmissionSummary,
            outcome: eviMail.outcome,
            customLayoutLogoUrl: eviMail.customLayoutLogoUrl,  
        
        )
        

        return emailItem
    }
    
    // MARK: - Helper Mappers
    
    /// Determina il livello di certificazione dai kinds
    private static func determineCertificationLevel(_ kinds: [String]?) -> String {
        guard let kinds = kinds else { return "Standard" }
        
        // Cerca indicatori di certificazione avanzata
        let advancedKeywords = ["advanced", "enhanced", "premium", "full"]
        let hasAdvanced = kinds.contains { kind in
            advancedKeywords.contains { kind.lowercased().contains($0) }
        }
        
        return hasAdvanced ? "Advanced" : "Standard"
    }
    
    /// Mappa il language code dall'API
    private static func mapLanguage(_ apiLanguage: String?) -> String {
        guard let lang = apiLanguage?.lowercased() else { return "English" }
        
        switch lang {
        case "en", "en-us", "en-gb":
            return "English"
        case "it", "it-it":
            return "Italian"
        case "es", "es-es":
            return "Spanish"
        case "fr", "fr-fr":
            return "French"
        case "de", "de-de":
            return "German"
        default:
            return "English"
        }
    }
    
    /// Determina l'aspect/layout usato
    private static func determineAspect(_ eviMail: EviMail) -> String {
        // Se c'è un customLayoutLogoUrl, è custom
        if eviMail.customLayoutLogoUrl != nil {
            return "Custom Layout"
        }
        
        // Altrimenti usa il layout standard certificato
        return "Standard Certified"
    }
    
    /// Determina se il captcha è richiesto
    private static func determineCaptchaRequirement(_ eviMail: EviMail) -> Bool {
        // Il captcha è richiesto se c'è un access control method
        if let method = eviMail.evidenceAccessControlMethod {
            return method.lowercased().contains("captcha")
        }
        return false
    }
    
    /// Determina se è permesso accettare/rifiutare
    private static func determineAgreementAllowed(_ eviMail: EviMail) -> Bool {
        // Se ci sono accept/reject reasons configurate, l'agreement è permesso
        if let acceptReasons = eviMail.acceptReasons, !acceptReasons.isEmpty {
            return true
        }
        if let rejectReasons = eviMail.rejectReasons, !rejectReasons.isEmpty {
            return true
        }
        // Default: permetti agreement se ci sono commitment options
        return eviMail.commitmentOptions != nil
    }
    
    /// Determina il tipo di controllo accesso
    private static func determineAccessControl(_ eviMail: EviMail) -> String? {
        guard let method = eviMail.evidenceAccessControlMethod else {
            return nil
        }
        
        switch method.lowercased() {
        case "captcha":
            return "Visual verification (CAPTCHA) required"
        case "password":
            return "Password protection enabled"
        case "challenge":
            return "Security question must be answered"
        case "pin":
            return "PIN code verification required"
        default:
            return "Access control: \(method)"
        }
    }
    
    /// Determina il tipo di firma/notifica
    private static func determineSignatureNotice(_ eviMail: EviMail) -> String? {
        // Se ci sono affidavit kinds, costruisci la descrizione
        guard let kinds = eviMail.affidavitKinds, !kinds.isEmpty else {
            return nil
        }
        
        let kindsString = kinds.joined(separator: ", ")
        return "Digital signature with: \(kindsString)"
    }
    
    // MARK: - Attachments Mapping
    
    private static func mapAttachments(_ apiAttachments: [EviMailAttachment]?) -> [EmailAttachment] {
        guard let apiAttachments = apiAttachments else { return [] }
        
        return apiAttachments.map { attachment in
            EmailAttachment(
                id: attachment.uniqueId,
                name: attachment.displayName,
                filename: attachment.filename,
                size: attachment.contentLength,
                mimeType: attachment.mimeType,
                hash: attachment.hash,
                kind: EmailAttachment.Kind.from(mimeType: attachment.mimeType)
            )
        }
    }
    
    // MARK: - Status Mapping
    
    /// Mappa lo stato eCertia allo stato locale
    private static func mapStatus(_ state: String?) -> EmailStatus {
        guard let state = state?.lowercased() else { return .new }
        
        switch state {
        case "new": return .new
        case "ready": return .ready
        case "sent": return .sent
        case "dispatched": return .dispatched
        case "delivered": return .delivered
        case "read": return .read
        case "replied": return .replied
        case "expired": return .expired
        case "failed": return .failed
        case "closed": return .closed
        default: return .new
        }
    }
    
    // MARK: - Events Mapping
    
    /// Crea array eventi dettagliati (per timeline)
    private static func mapEvents(_ eviMail: EviMail) -> [EmailEvent] {
        var events: [EmailEvent] = []
        
        // PREPARATION
        if let newOn = eviMail.newOn, let date = parseDate(newOn) {
            events.append(EmailEvent(
                id: UUID(uuidString: eviMail.uniqueId ?? "") ?? UUID(),
                event: .preparation,
                state: .preparation(.pending),
                timestampUTC: date,
                description: "Message submitted and certified"
            ))
        }
        
        if let readyOn = eviMail.readyOn, let date = parseDate(readyOn) {
            events.append(EmailEvent(
                id: UUID(uuidString: eviMail.uniqueId ?? "") ?? UUID(),
                event: .preparation,
                state: .preparation(.ready),
                timestampUTC: date,
                description: "Message ready for transmission"
            ))
        }
        
        // SENDING
        if let sentOn = eviMail.sentOn, let date = parseDate(sentOn) {
            events.append(EmailEvent(
                id: UUID(uuidString: eviMail.uniqueId ?? "") ?? UUID(),
                event: .sending,
                state: .sending(.sent),
                timestampUTC: date,
                description: "Transmission result confirmed"
            ))
        }
        
        if let dispatchedOn = eviMail.dispatchedOn, let date = parseDate(dispatchedOn) {
            events.append(EmailEvent(
                id: UUID(uuidString: eviMail.uniqueId ?? "") ?? UUID(),
                event: .sending,
                state: .sending(.dispatched),
                timestampUTC: date,
                description: "Message dispatched to recipient"
            ))
        }
        
        if let deliveredOn = eviMail.deliveredOn, let date = parseDate(deliveredOn) {
            events.append(EmailEvent(
                id: UUID(uuidString: eviMail.uniqueId ?? "") ?? UUID(),
                event: .sending,
                state: .sending(.delivered),
                timestampUTC: date,
                description: "Successfully delivered to mailbox"
            ))
        }
        
        if let failedOn = eviMail.failedOn, let date = parseDate(failedOn) {
            events.append(EmailEvent(
                id: UUID(uuidString: eviMail.uniqueId ?? "") ?? UUID(),
                event: .sending,
                state: .sending(.failed),
                timestampUTC: date,
                description: "Transmission failed: \(eviMail.xmissionSummary ?? "Unknown error")"
            ))
        }
            
            // READING (read)
            if let readOn = eviMail.readOn, let date = parseDate(readOn) {
                events.append(EmailEvent(
                    id: UUID(uuidString: eviMail.uniqueId ?? "") ?? UUID(),
                    event: .reading,
                    state: .reading(.opened),
                    timestampUTC: date,
                    description: "Message opened by recipient"
                ))
            }else if let repliedOn = eviMail.repliedOn, let date = parseDate(repliedOn){
                events.append(EmailEvent(
                    id: UUID(uuidString: eviMail.uniqueId ?? "") ?? UUID(),
                    event: .reading,
                    state: .reading(.opened),
                    timestampUTC: date,
                    description: "Message opened by recipient"
                ))
            }else if let waitingOn = eviMail.deliveredOn,eviMail.readOn == nil,let date = parseDate(waitingOn) {
                let waitingDate = date.addingTimeInterval(1)
                events.append(EmailEvent(
                    id: UUID(uuidString: eviMail.uniqueId ?? "") ?? UUID(),
                    event: .reading,
                    state: .reading(.waiting),
                    timestampUTC: waitingDate,
                    description: "Awaiting recipient to open message"
                ))
            }
            
            
            // DECISION (replied)
            if let acceptedOn = eviMail.acceptedOn, let date = parseDate(acceptedOn) {
                // ACCETTATO
                events.append(EmailEvent(
                    id: UUID(uuidString: eviMail.uniqueId ?? "") ?? UUID(),
                    event: .decision,
                    state: .decision(.contentAccepted),
                    timestampUTC: date,
                    description: "Content formally accepted by recipient"
                ))
            } else if let rejectedOn = eviMail.rejectedOn, let date = parseDate(rejectedOn) {
                // RIFIUTATO
                events.append(EmailEvent(
                    id: UUID(uuidString: eviMail.uniqueId ?? "") ?? UUID(),
                    event: .decision,
                    state: .decision(.contentRejected),
                    timestampUTC: date,
                    description: "Content rejected by recipient"
                ))
            }else if let waitingDecision = eviMail.readOn, eviMail.repliedOn == nil, let date = parseDate(waitingDecision) {
                //DECISION (waiting for replying)
                events.append(EmailEvent(
                    id: UUID(uuidString: eviMail.uniqueId ?? "") ?? UUID(),
                    event: .decision,
                    state: .decision(.contentWaiting),
                    timestampUTC: date,
                    description: "Awaiting recipient's formal response"
                ))
            }
            
            //CLOSED
            if let expiredOn = eviMail.expiredOn, let date = parseDate(expiredOn) {
                events.append(EmailEvent(
                    id: UUID(uuidString: eviMail.uniqueId ?? "") ?? UUID(),
                    event: .closing,
                    state: .closing(.closed),
                    timestampUTC: date,
                    description: "Monitoring closed"
                ))
            }
            
            
            return events.sorted { $0.timestampUTC < $1.timestampUTC }
        }
    
    /// Determina lo stato dei 3 eventi fissi (per le 3 icone)
    private static func mapEventStatus(_ eviMail: EviMail) -> EmailEventStatus {
        
        // 1. STATO INVIO
        let sendingStatus: SendingStatus = {
            if eviMail.xmissionResult == false {
                return .failed
            }
            
            if eviMail.failedOn != nil {
                return .failed
            }
            
            if eviMail.state?.lowercased() == "failed" {
                return .failed
            }
            
            if eviMail.deliveredOn != nil || eviMail.dispatchedOn != nil || eviMail.sentOn != nil {
                return .sent
            }
            return .waiting
        }()
        
        // 2. STATO LETTURA
        let readingStatus: ReadingStatus = {
            if eviMail.readOn != nil {
                return .opened
            }
            if eviMail.repliedOn != nil {
                // Se ha risposto, deve aver letto
                return .opened
            }
            return .waiting
        }()
        
        // 3. STATO CONTENUTO (DECISION)
        let contentStatus: ContentStatus = {
            if eviMail.acceptedOn != nil {
                return .accepted
            }
            
            if eviMail.rejectedOn != nil {
                return .rejected
            }
            
            if eviMail.repliedOn != nil {
                return .waiting
            }
            
            // ⚪ IN ATTESA DI DECISIONE
            return .waiting
        }()
        
        return EmailEventStatus(
            sendingStatus: sendingStatus,
            readingStatus: readingStatus,
            contentStatus: contentStatus
        )
    }
    
    // MARK: - Date Formatting
    
    /// Formatta la data per i dettagli (es. "12/03/2025 14:30:45")
    private static func formatDetailDate(_ dateString: String?) -> String? {
        guard let dateString = dateString,
              let date = parseDate(dateString) else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter.string(from: date)
    }
    
    /// Formatta la data per la lista (es. "12/03/25")
    private static func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString,
              let date = parseDate(dateString) else {
            return "N/A"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
    
    /// Parse ISO8601 date string
    private static func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = fallbackFormatter.date(from: dateString) {
            return date
        }
        
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return fallbackFormatter.date(from: dateString)
    }
}
