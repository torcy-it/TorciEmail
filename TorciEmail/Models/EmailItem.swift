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
    let emailObject: String
    let emailDescription: String
    let date: String
    let status: EmailStatus
    
    // 3 stati fissi per le icone nella lista
    let eventStatus: EmailEventStatus
    
    // Array completo eventi per timeline dettagliata (futuro)
    let events: [EmailEvent]
    
    let attachments: [EmailAttachment]
    
    init(
        id: String = UUID().uuidString,
        senderName: String,
        emailObject: String,
        emailDescription: String,
        date: String,
        status: EmailStatus,
        eventStatus: EmailEventStatus,
        events: [EmailEvent] = [],  // Default vuoto se non fornito
        attachments: [EmailAttachment] = []  // Default vuoto se non fornito
    ) {
        self.id = id
        self.senderName = senderName
        self.emailObject = emailObject
        self.emailDescription = emailDescription
        self.date = date
        self.status = status
        self.eventStatus = eventStatus
        self.events = events
        self.attachments = attachments
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
}

// MARK: - Preview Helpers
extension EmailItem {
    /// Esempio per preview
    static var example: EmailItem {
        EmailItem(
            id: "example-123",
            senderName: "Mario Rossi",
            emailObject: "Test Email",
            emailDescription: "Questa è una email di test",
            date: "04/02/26",
            status: .delivered,
            eventStatus: EmailEventStatus(
                sendingStatus: .sent,
                readingStatus: .waiting,
                contentStatus: .waiting
            ),
            events: [],
            attachments: []
        )
    }
    
    /// Esempio con tutti gli stati completati
    static var completedExample: EmailItem {
        EmailItem(
            id: "completed-456",
            senderName: "Luca Bianchi",
            emailObject: "Email Completata",
            emailDescription: "Email con tutti gli eventi completati",
            date: "04/02/26",
            status: .closed,
            eventStatus: EmailEventStatus(
                sendingStatus: .sent,
                readingStatus: .opened,
                contentStatus: .accepted
            ),
            events: [],
            attachments: []
        )
    }
    
    /// Esempio con invio fallito
    static var failedExample: EmailItem {
        EmailItem(
            id: "failed-789",
            senderName: "Giovanni Verdi",
            emailObject: "Email Fallita",
            emailDescription: "Email con invio fallito",
            date: "04/02/26",
            status: .failed,
            eventStatus: EmailEventStatus(
                sendingStatus: .failed,
                readingStatus: .waiting,
                contentStatus: .waiting
            ),
            events: [],
            attachments: []
        )
    }
}
