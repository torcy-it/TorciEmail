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
        // Sender name - priorità: issuer.legalName > from > emailAddress > "Unknown"
        let senderName: String = {
            if let legalName = eviMail.issuer?.legalName, !legalName.isEmpty {
                return legalName
            }
            if let from = eviMail.from, !from.isEmpty {
                return from
            }
            if let email = eviMail.issuer?.emailAddress {
                return email
            }
            return "Unknown Sender"
        }()
        
        let subject = eviMail.subject ?? "No Subject"
        let body = eviMail.body ?? ""
        let date = formatDate(eviMail.creationDate)
        let status = mapStatus(eviMail.state)
        let events = mapEvents(eviMail)
        let attachments: [EmailAttachment] = [] // TODO: se il server invia attachments
        
        return EmailItem(
            id: eviMail.uniqueId ?? UUID().uuidString,
            senderName: senderName,
            emailObject: subject,
            emailDescription: body,
            date: date,
            status: status,
            events: events,
            attachments: attachments
        )
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
        case "accepted": return .accepted
        case "expired": return .expired
        case "failed": return .failed
        case "closed": return .closed
        default: return .new
        }
    }
    
    /// Crea gli eventi dalla timeline dell'email
    private static func mapEvents(_ eviMail: EviMail) -> [EmailEvent] {
        var events: [EmailEvent] = []
        
        // New/Created
        if let creationDate = eviMail.creationDate, let date = parseDate(creationDate) {
            events.append(EmailEvent(
                event: .sent,
                state: .sent(.sent),
                timestampUTC: date
            ))
        }
        
        // Ready
        if let readyOn = eviMail.readyOn, let date = parseDate(readyOn) {
            events.append(EmailEvent(
                event: .sent,
                state: .sent(.sent),
                timestampUTC: date
            ))
        }
        
        // Sent
        if let sentOn = eviMail.sentOn, let date = parseDate(sentOn) {
            events.append(EmailEvent(
                event: .sent,
                state: .sent(.sent),
                timestampUTC: date
            ))
        }
        
        // Dispatched
        if let dispatchedOn = eviMail.dispatchedOn, let date = parseDate(dispatchedOn) {
            events.append(EmailEvent(
                event: .sent,
                state: .sent(.dispatched),
                timestampUTC: date
            ))
        }
        
        // Delivered
        if let deliveredOn = eviMail.deliveredOn, let date = parseDate(deliveredOn) {
            events.append(EmailEvent(
                event: .sent,
                state: .sent(.delivered),
                timestampUTC: date
            ))
        }
        
        // Read/Open
        if let readOn = eviMail.readOn, let date = parseDate(readOn) {
            events.append(EmailEvent(
                event: .open,
                state: .open(.opened),
                timestampUTC: date
            ))
        }
        
        // Replied
        if let repliedOn = eviMail.repliedOn, let date = parseDate(repliedOn) {
            events.append(EmailEvent(
                event: .decision,
                state: .decision(.accepted),
                timestampUTC: date
            ))
        }
        
        // Accepted
        if let acceptedOn = eviMail.acceptedOn, let date = parseDate(acceptedOn) {
            events.append(EmailEvent(
                event: .decision,
                state: .decision(.accepted),
                timestampUTC: date
            ))
        }
        
        // Expired
        if let expiredOn = eviMail.expiredOn, let date = parseDate(expiredOn) {
            events.append(EmailEvent(
                event: .decision,
                state: .decision(.waiting),
                timestampUTC: date
            ))
        }
        
        return events.sorted { $0.timestampUTC < $1.timestampUTC }
    }
    
    /// Formatta la data per la UI (es. "12/03/25")
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
        // Prima prova con fractional seconds
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        // Fallback senza fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        // Fallback con DateFormatter per altri formati
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = fallbackFormatter.date(from: dateString) {
            return date
        }
        
        // Ultimo tentativo senza millisecondi
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return fallbackFormatter.date(from: dateString)
    }
}
