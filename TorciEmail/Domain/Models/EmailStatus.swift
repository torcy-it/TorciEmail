//
//  EmailStatus.swift
//  TorciEmail
//
//  Stato ad alto livello della email certificata.
//

import SwiftUI

/// Stati applicativi usati per badge e filtro mailbox.
enum EmailStatus: Hashable {
    case new, ready, sent, dispatched, delivered
    case read, draft, submitted, expired, replied
    case failed, closed
    
    /// Indica se lo stato conclude definitivamente il ciclo dell'email.
    var isFinal: Bool {
        switch self {
        case .closed, .expired, .failed:
            return true
        default:
            return false
        }
    }
    
    /// Etichetta visuale per badge/lista.
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
    
    /// Colore di sfondo del badge stato in UI.
    var badgeBackground: Color {
        switch self {

        // NEUTRO / ATTESA
        case .new, .draft, .closed:
            return .gray

        // INVIO (teal)
        case .ready, .sent, .dispatched, .delivered, .submitted:
            return .tail

        // LETTURA (sky)
        case .read, .replied:
            return .sky

        // ERROR / NEGATIVO (red)
        case .failed, .expired:
            return .lightRed
        }
    }

}

