//
//  EmailStatus.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//

import SwiftUI

enum EmailStatus: Hashable {
    case new, ready, sent, dispatched, delivered
    case read, replied, accepted, expired
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
        case .new: return "New"
        case .ready: return "Ready"
        case .sent: return "Sent"
        case .dispatched: return "Dispatched"
        case .delivered: return "Delivered"
        case .read: return "Read"
        case .replied: return "Replied"
        case .accepted: return "Accepted"
        case .expired: return "Expired"
        case .failed: return "Failed"
        case .closed: return "Closed"
        }
    }
    
    var badgeBackground: Color {
        switch self {
        case .new:
            return .blue
        case .ready:
            return .cyan
        case .sent:
            return .orange
        case .dispatched:
            return .yellow
        case .delivered:
            return .green
        case .read:
            return .teal
        case .replied:
            return .purple
        case .accepted:
            return .mint
        case .expired:
            return .gray
        case .failed:
            return .red
        case .closed:
            return .secondary
        }
    }
}

