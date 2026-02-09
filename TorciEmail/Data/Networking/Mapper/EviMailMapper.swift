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
        //print("\(eviMail.uniqueId) ---- \(eviMail.expiredOn)")
        return EmailItem(
            id: eviMail.uniqueId ?? UUID().uuidString,
            senderName: eviMail.issuer?.legalName ?? "Unknown",
            senderEmail: eviMail.issuer?.emailAddress ?? "",
            recipientName: eviMail.recipient?.legalName ?? "Unknown",
            recipientEmail: eviMail.recipient?.emailAddress ?? "",
            carbonCopy: eviMail.carbonCopy ?? [],
            emailObject: eviMail.subject ?? "No Subject",
            emailDescription: eviMail.body ?? "",
            date: displayDate,
            status: status,
            eventStatus: eventStatus,
            events: events,
            attachments: attachments,
            affidavits: affidavits,
            certificationLevel: (eviMail.affidavitKinds ?? []).contains { $0.localizedCaseInsensitiveContains("advanced") } ? "Advanced" : "Standard",
            sourceChannel: eviMail.sourceChannel,
            creationDate: formatDetailDate(eviMail.creationDate),
            admissionDate: formatDetailDate(eviMail.readyOn),
            dispatchedDate: formatDetailDate(eviMail.dispatchedOn),
            openedDate: formatDetailDate(eviMail.readOn),
            repliedDate: formatDetailDate(eviMail.repliedOn),
            expirationDate: formatDetailDate(eviMail.expiredOn),
            onlineRetentionPeriod: eviMail.onlineRetentionPeriod,
            affidavitKinds: eviMail.affidavitKinds ?? [],
            language: "en",
            aspect: "Certificato",
            totalSize: totalSize > 0 ? totalSize : nil,
            contentSize: eviMail.body?.count,
            requiresCaptcha: false,
            allowsAgreement: true,
            commentsAllowed: true,
            accessControl: nil,
            signatureNotice: nil,
            acceptOrRejectComments: eviMail.acceptOrRejectComments,
            costCentre: eviMail.costCentre,
            xmissionResult: eviMail.xmissionResult,
            xmissionSummary: eviMail.xmissionSummary
        )
    }
    
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
    
    /// Crea array eventi dettagliati (per timeline futura)
    private static func mapEvents(_ eviMail: EviMail) -> [EmailEvent] {
        var events: [EmailEvent] = []
        
        // PREPARATION
        if let newOn = eviMail.newOn, let date = parseDate(newOn) {
            events.append(EmailEvent(
                event: .preparation,
                state: .preparation(.pending),
                timestampUTC: date
            ))
        }
        
        if let readyOn = eviMail.readyOn, let date = parseDate(readyOn) {
            events.append(EmailEvent(
                event: .preparation,
                state: .preparation(.ready),
                timestampUTC: date
            ))
        }
        
        // SENDING
        if let sentOn = eviMail.sentOn, let date = parseDate(sentOn) {
            events.append(EmailEvent(
                event: .sending,
                state: .sending(.sent),
                timestampUTC: date
            ))
        }
        
        if let dispatchedOn = eviMail.dispatchedOn, let date = parseDate(dispatchedOn) {
            events.append(EmailEvent(
                event: .sending,
                state: .sending(.dispatched),
                timestampUTC: date
            ))
        }
        
        if let deliveredOn = eviMail.deliveredOn, let date = parseDate(deliveredOn) {
            events.append(EmailEvent(
                event: .sending,
                state: .sending(.delivered),
                timestampUTC: date
            ))
        }
        
        if eviMail.xmissionResult == false,
           let failedDate = eviMail.lastStateChangeDate,
           let date = parseDate(failedDate) {
            events.append(EmailEvent(
                event: .sending,
                state: .sending(.failed),
                timestampUTC: date
            ))
        }
        
        // DELIVERY (waiting for open)
        if let deliveredOn = eviMail.deliveredOn,
           eviMail.readOn == nil,
           let date = parseDate(deliveredOn) {
            let waitingDate = date.addingTimeInterval(1)
            events.append(EmailEvent(
                event: .delivery,
                state: .delivery(.waiting),
                timestampUTC: waitingDate
            ))
        }
        
        // READING
        if let readOn = eviMail.readOn, let date = parseDate(readOn) {
            events.append(EmailEvent(
                event: .reading,
                state: .reading(.opened),
                timestampUTC: date
            ))
        }
        
        // DECISION
        if let acceptedOn = eviMail.acceptedOn, let date = parseDate(acceptedOn) {
            events.append(EmailEvent(
                event: .decision,
                state: .decision(.contentAccepted),
                timestampUTC: date
            ))
        } else if let repliedOn = eviMail.repliedOn, let date = parseDate(repliedOn) {
            events.append(EmailEvent(
                event: .decision,
                state: .decision(.contentAccepted),
                timestampUTC: date
            ))
        } else if eviMail.state?.lowercased() == "closed",
                  let outcome = eviMail.outcome?.lowercased(),
                  outcome.contains("reject") || outcome.contains("refused"),
                  let closedDate = eviMail.lastStateChangeDate,
                  let date = parseDate(closedDate) {
            events.append(EmailEvent(
                event: .decision,
                state: .decision(.contentRejected),
                timestampUTC: date
            ))
        } else if let expiredOn = eviMail.expiredOn, let date = parseDate(expiredOn) {
            events.append(EmailEvent(
                event: .decision,
                state: .decision(.expired),
                timestampUTC: date
            ))
        } else if let readOn = eviMail.readOn,
                  eviMail.acceptedOn == nil,
                  eviMail.repliedOn == nil,
                  eviMail.expiredOn == nil,
                  let date = parseDate(readOn) {
            let waitingDate = date.addingTimeInterval(1)
            events.append(EmailEvent(
                event: .decision,
                state: .decision(.waitingDecision),
                timestampUTC: waitingDate
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
            return .waiting
        }()
        
        // 3. STATO CONTENUTO
        let contentStatus: ContentStatus = {
            if eviMail.acceptedOn != nil || eviMail.repliedOn != nil {
                return .accepted
            }
            if let outcome = eviMail.outcome?.lowercased(),
               outcome.contains("reject") || outcome.contains("refused") {
                return .rejected
            }
            if eviMail.expiredOn != nil {
                return .rejected
            }
            return .waiting
        }()
        
        return EmailEventStatus(
            sendingStatus: sendingStatus,
            readingStatus: readingStatus,
            contentStatus: contentStatus
        )
    }
    
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
