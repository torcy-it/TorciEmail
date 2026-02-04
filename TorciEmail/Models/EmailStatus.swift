//
//  EmailStatus.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//

import SwiftUI

enum EmailStatus: Hashable {
    case new, ready, sent, dispatched, delivered
    case read, draft, submitted, expired, replied
    case failed, closed
    
    var isFinal: Bool {
        switch self {
        case .closed, .expired, .failed:
            return true
        default:
            return false
        }
    }
    
    var title: String {
        switch self {
        case .replied: return "REPLIED"
        case .new: return "PENDING"
        case .ready: return "READY"
        case .sent: return "SENT"
        case .dispatched: return "DISPATCHED"
        case .delivered: return "DELIVERED"
        case .read: return "READ"
        case .submitted: return "SUBMITTED"
        case .failed: return "FAILED"
        case .expired: return "CLOSED"
        case .closed: return "CLOSED"
        case .draft: return "DRAFT"
        }
    }
    
    var badgeBackground: Color {
        switch self {
        case .new, .dispatched, .expired, .closed, .draft:
            return .gray
        case .ready, .sent, .delivered, .read, .replied, .submitted:
            return .mint
        case .failed:
            return .red
        }
    }

}

