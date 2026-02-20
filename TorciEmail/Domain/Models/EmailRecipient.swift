//
//  EmailRecipient.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 13/02/26.
//


import Foundation

// MARK: - Email Recipient Model
struct EmailRecipient: Identifiable, Equatable {
    let id = UUID()
    let email: String
}