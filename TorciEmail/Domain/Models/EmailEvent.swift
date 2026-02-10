//
//  EmailEvent.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 04/02/26.
//

import Foundation
import SwiftUI

struct EmailEvent: Hashable {
    let id: UUID
    let event: EventType
    let state: EventState
    let timestampUTC: Date
    let description: String
    
    init(
        id: UUID = UUID(),
        event: EventType,
        state: EventState,
        timestampUTC: Date,
        description: String
    ) {
        self.id = id
        self.event = event
        self.state = state
        self.timestampUTC = timestampUTC
        self.description = description 
    }
}
enum EventType: Hashable {
    case preparation    // Preparazione/attesa invio
    case sending        // Invio in corso
    case reading        // Apertura/lettura
    case decision       // Decisione sul contenuto
    case closing        //fine del monitoraggio
    
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
            
        // READING (attesa apertura)
        case (.reading, .reading(.waiting)):
            return "IconWaitOpenEnv"
            
        // READING (apertura)
        case (.reading, .reading(.opened)):
            return "IconOpenEnv"
            
        // DECISION (accettazione/rifiuto contenuto)
        case (.decision, .decision(.contentWaiting)):
            return "IconContentWait"
        case (.decision, .decision(.contentAccepted)):
            return "IconContentAcc"
        case (.decision, .decision(.contentRejected)):
            return "IconContentRej"
            
        default:
            return "IconWaitEnv"
        }
    }
    
    func tint(for state: EventState) -> Color {
        switch (self, state) {
        // PREPARATION
        case (.preparation, .preparation(.pending)):
            return .gray
        case (.preparation, .preparation(.ready)):
            return .tail
            
        // SENDING
        case (.sending, .sending(.sent)):
            return .tail
        case (.sending, .sending(.dispatched)):
            return .tail
        case (.sending, .sending(.delivered)):
            return .tail
        case (.sending, .sending(.failed)):
            return .lightRed
            
        // READING
        case (.reading, .reading(.waiting)):
            return .gray
        case (.reading, .reading(.opened)):
            return .lightGreen
            
        // DECISION
        case (.decision, .decision(.contentWaiting)):
            return .gray
        case (.decision, .decision(.contentAccepted)):
            return .sky
        case (.decision, .decision(.contentRejected)):
            return .sky
            
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
        case (.reading, .reading(.waiting)):
            return "In attesa di apertura"
        case (.reading, .reading(.opened)):
            return "Aperto"
        case (.decision, .decision(.contentWaiting)):
            return "In attesa di risposta"
        case (.decision, .decision(.contentAccepted)):
            return "Contenuto accettato"
        case (.decision, .decision(.contentRejected)):
            return "Contenuto rifiutato"
        case (.closing, .closing(.closed)):
            return "Scaduto"
        default:
            return "Stato sconosciuto"
        }
    }
}

enum EventState: Hashable {
    case preparation(PreparationState)
    case sending(SendingState)
    case reading(ReadingState)
    case decision(DecisionState)
    case closing(ClosingState)
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

enum ReadingState: Hashable {
    case waiting     //in attesa di lettura
    case opened     // Aperto
}

enum DecisionState: Hashable {
    case contentWaiting    // In attesa di decisione
    case contentAccepted    // Contenuto accettato
    case contentRejected    // Contenuto rifiutato
}

enum ClosingState: Hashable {
    case closed
}

