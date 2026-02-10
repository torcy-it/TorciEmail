//
//  EmailEventStatus.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 04/02/26.
//

import Foundation
import SwiftUI

// Modello: stato complessivo dell'email con 3 categorie fisse
struct EmailEventStatus: Hashable {
    let sendingStatus: SendingStatus
    let readingStatus: ReadingStatus
    let contentStatus: ContentStatus
}

// CATEGORIA 1: Invio
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
        case .waiting: return "In attesa di invio"
        case .sent: return "Inviato"
        case .failed: return "Invio fallito"
        }
    }
}

// CATEGORIA 2: Lettura
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
        case .waiting: return "In attesa di apertura"
        case .opened: return "Aperto"
        }
    }
}

// CATEGORIA 3: Contenuto
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
        case .waiting: return "In attesa di risposta"
        case .accepted: return "Contenuto accettato"
        case .rejected: return "Contenuto rifiutato"
        }
    }
}
