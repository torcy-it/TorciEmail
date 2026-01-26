//
//  EviMailCertificateType.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 24/01/26.
//


//
//  CertificateTypes.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import SwiftUI

// MARK: - EviMail Certificate Types
enum EviMailCertificateType: String, CaseIterable, Codable {
    case submitted = "EviMail::Submitted"
    case submittedAdvanced = "EviMail::Submitted::Advanced"
    case transmissionResult = "EviMail::Transmission::Result"
    case deliveryResult = "EviMail::Delivery::Result"
    case read = "EviMail::Read"
    case committed = "EviMail::Committed"
    case committedAdvanced = "EviMail::Committed::Advanced"
    case closed = "EviMail::Closed"
    case closedAdvanced = "EviMail::Closed::Advanced"
    case complete = "EviMail::Complete"
    case completeAdvanced = "EviMail::Complete::Advanced"
    case onDemand = "EviMail::OnDemand"
    case event = "EviMail::Event"
    case failed = "EviMail::Failed"
    
    // Initialize from API kind string
    init?(apiKind: String) {
        // Supporta:
        // "EviMail:Submitted:Advanced"
        // "EviMail::Submitted::Advanced"
        // e varianti miste
        var s = apiKind.trimmingCharacters(in: .whitespacesAndNewlines)

        // Uniforma il prefisso
        if s.hasPrefix("EviMail:") {
            s = s.replacingOccurrences(of: "EviMail:", with: "EviMail::")
        } else if s.hasPrefix("EviMail::") == false, s.hasPrefix("EviMail") {
            // se arriva "EviMailSubmitted..." (strano) lo lasciamo com'è
        }

        // Uniforma i separatori: qualsiasi ":" singolo diventa "::"
        s = s.replacingOccurrences(of: "::::", with: "::")
        s = s.replacingOccurrences(of: ":::", with: "::")
        s = s.replacingOccurrences(of: ":", with: "::")
        s = s.replacingOccurrences(of: "::::", with: "::")
        s = s.replacingOccurrences(of: "::::", with: "::")

        self.init(rawValue: s)
    }
    
    var title: String {
        switch self {
        case .submitted: return "Message Submitted"
        case .submittedAdvanced: return "Message Submitted (Advanced)"
        case .transmissionResult: return "Transmission Result"
        case .deliveryResult: return "Delivery Result"
        case .read: return "Message Read"
        case .committed: return "Content Committed"
        case .committedAdvanced: return "Content Committed (Advanced)"
        case .closed: return "Tracking Closed"
        case .closedAdvanced: return "Tracking Closed (Advanced)"
        case .complete: return "Certificate Complete"
        case .completeAdvanced: return "Certificate Complete (Advanced)"
        case .onDemand: return "On-Demand Certificate"
        case .event: return "Event Recorded"
        case .failed: return "Processing Failed"
        }
    }
    
    var description: String {
        switch self {
        case .submitted:
            return "Message was taken in charge, sealed, and queued for delivery"
        case .submittedAdvanced:
            return "Message submitted with additional graphical certificate attached"
        case .transmissionResult:
            return "Confirms whether message was successfully sent to recipient's mail server or if sending failed"
        case .deliveryResult:
            return "Confirms whether recipient's server successfully delivered the message to their mailbox or declared it undeliverable"
        case .read:
            return "Recipient has opened and read your message"
        case .committed:
            return "Recipient has formally accepted or rejected the message and its contents"
        case .committedAdvanced:
            return "Content committed with additional graphical certificate attached"
        case .closed:
            return "Tracking has ended and a final summary certificate has been generated"
        case .closedAdvanced:
            return "Tracking closed with additional graphical certificate attached"
        case .complete:
            return "Certificate received with information collected so far"
        case .completeAdvanced:
            return "Certificate complete with additional graphical certificate attached"
        case .onDemand:
            return "On-demand certificate requested and received with current information"
        case .event:
            return "A relevant event was recorded even if it does not match a specific predefined category"
        case .failed:
            return "An error occurred making it impossible to continue processing your message"
        }
    }
    
    var iconName: String {
        switch self {
        case .submitted, .submittedAdvanced: return "checkmark.seal"
        case .transmissionResult: return "arrow.up.circle"
        case .deliveryResult: return "envelope.badge"
        case .read: return "envelope.open"
        case .committed, .committedAdvanced: return "hand.thumbsup"
        case .closed, .closedAdvanced: return "lock.shield"
        case .complete, .completeAdvanced: return "doc.badge.checkmark"
        case .onDemand: return "doc.text.magnifyingglass"
        case .event: return "bell.badge"
        case .failed: return "exclamationmark.triangle"
        }
    }
    
    var isAdvanced: Bool {
        switch self {
        case .submittedAdvanced, .committedAdvanced, .closedAdvanced, .completeAdvanced:
            return true
        default:
            return false
        }
    }
    
    var category: CertificateCategory {
        switch self {
        case .submitted, .submittedAdvanced: return .submission
        case .transmissionResult, .deliveryResult: return .delivery
        case .read: return .reading
        case .committed, .committedAdvanced: return .commitment
        case .closed, .closedAdvanced, .complete, .completeAdvanced, .onDemand: return .closure
        case .event: return .event
        case .failed: return .error
        }
    }
}

// MARK: - Certificate Categories
enum CertificateCategory: String, CaseIterable {
    case submission = "Submission"
    case delivery = "Delivery"
    case reading = "Reading"
    case commitment = "Commitment"
    case closure = "Closure"
    case event = "Event"
    case error = "Error"
    
    var color: Color {
        switch self {
        case .submission: return .blue
        case .delivery: return .green
        case .reading: return .purple
        case .commitment: return .green
        case .closure: return .indigo
        case .event: return .orange
        case .error: return .red
        }
    }
}