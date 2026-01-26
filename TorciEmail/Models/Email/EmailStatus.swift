//
//  EmailStatus.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 24/01/26.
//


//
//  EmailStatus.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import SwiftUI

// MARK: - Email Status
enum EmailStatus: String, CaseIterable, Codable {
    case new
    case ready
    case sent
    case delivered
    case open
    case answered
    case failed
    case closed
    
    // Initialize from API state
    init?(apiState: String) {
        switch apiState.lowercased() {
        case "new": self = .new
        case "ready": self = .ready
        case "sent": self = .sent
        case "delivered": self = .delivered
        case "read": self = .open
        case "answered": self = .answered
        case "failed": self = .failed
        case "closed": self = .closed
        default: return nil
        }
    }
}

// MARK: - EmailStatus Extensions
extension EmailStatus {
    var title: String {
        switch self {
        case .new: return "ONGOING"
        case .ready: return "READY"
        case .sent: return "SENT"
        case .delivered: return "DELIVERED"
        case .open: return "OPENED"
        case .answered: return "ANSWERED"
        case .failed: return "FAILED"
        case .closed: return "CLOSED"
        }
    }
    
    var tint: Color {
        switch self {
        case .new: return .gray
        case .ready: return .blue
        case .sent: return .blue
        case .delivered: return .green
        case .open: return .purple
        case .answered: return .mint
        case .failed: return .red
        case .closed: return .secondary
        }
    }
    
    var badgeBackground: Color {
        switch self {
        case .new: return Color.gray.opacity(0.25)
        case .ready: return Color.green.opacity(0.18)
        case .sent: return Color.green.opacity(0.14)
        case .delivered: return Color.green.opacity(0.18)
        case .open: return Color.green.opacity(0.18)
        case .answered: return Color.green.opacity(0.18)
        case .failed: return Color.red.opacity(0.18)
        case .closed: return Color.green.opacity(0.18)
        }
    }
    
    var isError: Bool { self == .failed }
    var isFinal: Bool { self == .failed || self == .closed }
    var isSuccess: Bool { [.delivered, .open, .answered, .closed].contains(self) }
}

// MARK: - Event Progress
enum EventProgress: Codable {
    case waiting
    case success
    case failed
}

struct EmailEventsProgress: Codable {
    let sent: EventProgress
    let open: EventProgress
    let decision: EventProgress
}

extension EmailStatus {
    var eventsProgress: EmailEventsProgress {
        switch self {
        case .new: return .init(sent: .waiting, open: .waiting, decision: .waiting)
        case .ready: return .init(sent: .waiting, open: .waiting, decision: .waiting)
        case .sent: return .init(sent: .success, open: .waiting, decision: .waiting)
        case .delivered: return .init(sent: .success, open: .waiting, decision: .waiting)
        case .open: return .init(sent: .success, open: .success, decision: .waiting)
        case .answered: return .init(sent: .success, open: .success, decision: .success)
        case .failed: return .init(sent: .failed, open: .waiting, decision: .waiting)
        case .closed: return .init(sent: .success, open: .success, decision: .success)
        }
    }
}