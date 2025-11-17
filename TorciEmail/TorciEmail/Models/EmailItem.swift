//
//  EmailItem.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import Foundation

struct EmailItem: Identifiable {
    let id = UUID()
    let senderName: String
    let emailObject: String
    let emailDescription: String
    let date: String
    let isRead: Bool
}
