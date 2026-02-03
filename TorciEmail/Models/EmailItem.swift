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
    let events: [EmailEvent]
    let attachments: [EmailAttachment]
    
    init(
        id: String = UUID().uuidString,
        senderName: String,
        emailObject: String,
        emailDescription: String,
        date: String,
        status: EmailStatus,
        events: [EmailEvent],
        attachments: [EmailAttachment]
    ) {
        self.id = id
        self.senderName = senderName
        self.emailObject = emailObject
        self.emailDescription = emailDescription
        self.date = date
        self.status = status
        self.events = events
        self.attachments = attachments
    }
}
