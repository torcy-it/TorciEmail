//
//  EmailEvent.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 04/02/26.
//

import Foundation
import SwiftUI

struct EmailEvent: Hashable {
    let event: EventType
    let state: EventState
    let timestampUTC: Date
}

enum EventType: Hashable {
    case preparation    // Preparazione/attesa invio
    case sending        // Invio in corso
    case delivery       // Attesa apertura
    case reading        // Apertura/lettura
    case decision       // Decisione sul contenuto
    
    func assetName(for state: EventState) -> String {
        switch (self, state) {
        // PREPARATION (attesa invio)
        case (.preparation, .preparation(.pending)):
            return "IconWaitEnv"
        case (.preparation, .preparation(.ready)):
            return "IconWaitEnv"
            
        // SENDING (invio)
        case (.sending, .sending(.sent)):
            return "IconSendEnv"
        case (.sending, .sending(.dispatched)):
            return "IconSendEnv"
        case (.sending, .sending(.delivered)):
            return "IconSendEnv"
        case (.sending, .sending(.failed)):
            return "IconRejectedEnv"
            
        // DELIVERY (attesa apertura)
        case (.delivery, .delivery(.waiting)):
            return "IconWaitOpenEnv"
            
        // READING (apertura)
        case (.reading, .reading(.opened)):
            return "IconOpenEnv"
            
        // DECISION (accettazione/rifiuto contenuto)
        case (.decision, .decision(.waitingDecision)):
            return "IconContentWait"
        case (.decision, .decision(.contentAccepted)):
            return "IconContentAcc"
        case (.decision, .decision(.contentRejected)):
            return "IconContentRej"
        case (.decision, .decision(.expired)):
            return "IconContentRej"
            
        default:
            return "IconWaitEnv" // Fallback
        }
    }
    
    func tint(for state: EventState) -> Color {
        switch (self, state) {
        // PREPARATION
        case (.preparation, .preparation(.pending)):
            return .gray
        case (.preparation, .preparation(.ready)):
            return .gray
            
        // SENDING
        case (.sending, .sending(.sent)):
            return .green
        case (.sending, .sending(.dispatched)):
            return .green
        case (.sending, .sending(.delivered)):
            return .green
        case (.sending, .sending(.failed)):
            return .red
            
        // DELIVERY
        case (.delivery, .delivery(.waiting)):
            return .gray
            
        // READING
        case (.reading, .reading(.opened)):
            return .green
            
        // DECISION
        case (.decision, .decision(.waitingDecision)):
            return .gray
        case (.decision, .decision(.contentAccepted)):
            return .green
        case (.decision, .decision(.contentRejected)):
            return .red
        case (.decision, .decision(.expired)):
            return .gray
            
        default:
            return .gray
        }
    }
    
    func description(for state: EventState) -> String {
        switch (self, state) {
        case (.preparation, .preparation(.pending)):
            return "In attesa di invio"
        case (.preparation, .preparation(.ready)):
            return "Pronto per l'invio"
        case (.sending, .sending(.sent)):
            return "Inviato"
        case (.sending, .sending(.dispatched)):
            return "Spedito al server destinatario"
        case (.sending, .sending(.delivered)):
            return "Consegnato"
        case (.sending, .sending(.failed)):
            return "Invio fallito"
        case (.delivery, .delivery(.waiting)):
            return "In attesa di apertura"
        case (.reading, .reading(.opened)):
            return "Aperto"
        case (.decision, .decision(.waitingDecision)):
            return "In attesa di risposta"
        case (.decision, .decision(.contentAccepted)):
            return "Contenuto accettato"
        case (.decision, .decision(.contentRejected)):
            return "Contenuto rifiutato"
        case (.decision, .decision(.expired)):
            return "Scaduto"
        default:
            return "Stato sconosciuto"
        }
    }
}

enum EventState: Hashable {
    case preparation(PreparationState)
    case sending(SendingState)
    case delivery(DeliveryState)
    case reading(ReadingState)
    case decision(DecisionState)
}

enum PreparationState: Hashable {
    case pending    // In attesa
    case ready      // Pronto
}

enum SendingState: Hashable {
    case sent       // Inviato
    case dispatched // Spedito
    case delivered  // Consegnato
    case failed     // Fallito
}

enum DeliveryState: Hashable {
    case waiting    // In attesa di apertura
}

enum ReadingState: Hashable {
    case opened     // Aperto
}

enum DecisionState: Hashable {
    case waitingDecision    // In attesa di decisione
    case contentAccepted    // Contenuto accettato
    case contentRejected    // Contenuto rifiutato
    case expired            // Scaduto
}
