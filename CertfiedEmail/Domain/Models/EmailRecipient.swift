//
//  EmailRecipient.swift
//  CertfiedEmail
//
//  Modello destinatario semplice per UI/compose.
//


import Foundation

// MARK: - Email Recipient Model
/// Rappresenta un destinatario email con identificatore locale.
struct EmailRecipient: Identifiable, Equatable {
    let id = UUID()
    let email: String
}