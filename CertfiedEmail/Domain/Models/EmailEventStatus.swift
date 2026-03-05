//
//  EmailEventStatus.swift
//  CertfiedEmail
//
//  Stati sintetici evento per rappresentazione compatta in mailbox.
//

import Foundation
import SwiftUI

/// Stato complessivo email diviso in invio, lettura e contenuto.
struct EmailEventStatus: Hashable {
    let sendingStatus: SendingStatus
    let readingStatus: ReadingStatus
    let contentStatus: ContentStatus
}

/// Stato del processo di invio.
enum SendingStatus: Hashable {
    case waiting    // In attesa di invio
    case sent       // Inviato con successo
    case failed     // Invio fallito
    
    var assetName: String {
        switch self {
        case .waiting: return "IconWaitEnv"
        case .sent: return "IconSendEnv"
        case .failed: return "IconRejectedEnv"
        }
    }
    
    var tint: Color {
        switch self {
        case .waiting: return .gray
        case .sent: return .tail
        case .failed: return .lightRed
        }
    }
    
    var description: String {
        switch self {
        case .waiting: return "Waiting to be sent"
        case .sent: return "Sent"
        case .failed: return "Sending failed"
        }
    }
}

/// Stato del processo di lettura da parte del destinatario.
enum ReadingStatus: Hashable {
    case waiting    // In attesa di apertura
    case opened     // Aperto
    
    var assetName: String {
        switch self {
        case .waiting: return "IconWaitOpenEnv"
        case .opened: return "IconOpenEnv"
        }
    }
    
    var tint: Color {
        switch self {
        case .waiting: return .gray
        case .opened: return .tail
        }
    }
    
    var description: String {
        switch self {
        case .waiting: return "Waiting to be opened"
        case .opened: return "Opened"
        }
    }
}

/// Stato della decisione sul contenuto.
enum ContentStatus: Hashable {
    case waiting    // In attesa di decisione
    case accepted   // Contenuto accettato
    case rejected   // Contenuto rifiutato
    
    var assetName: String {
        switch self {
        case .waiting: return "IconContentWait"
        case .accepted: return "IconContentAcc"
        case .rejected: return "IconContentRej"   
        }
    }
    
    var tint: Color {
        switch self {
        case .waiting: return .gray
        case .accepted: return .tail
        case .rejected: return .tail
        }
    }
    
    var description: String {
        switch self {
        case .waiting: return "Waiting for response"
        case .accepted: return "Content accepted"
        case .rejected: return "Content rejected"
        }
    }
}
