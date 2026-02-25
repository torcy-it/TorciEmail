//
//  EmailEvent.swift
//  TorciEmail
//
//  Modelli dominio per timeline eventi certificati.
//  Include mappature visuali per icona, colore e descrizione stato.
//

import Foundation
import SwiftUI

/// Evento puntuale nella timeline di una EviMail.
struct EmailEvent: Hashable {
    let id: UUID
    let affidavit: Affidavit?
    let event: EventType
    let state: EventState
    let timestampUTC: Date
    let description: String
    let color: Color
    let icon: String
    
    /// Inizializzatore evento con metadati timeline.
    init(
        id: UUID = UUID(),
        affidavit: Affidavit? = nil,
        event: EventType,
        state: EventState,
        timestampUTC: Date,
        description: String,
        color: Color,
        icon:  String
    ) {
        self.id = id
        self.affidavit = affidavit
        self.event = event
        self.state = state
        self.timestampUTC = timestampUTC
        self.description = description
        self.color = color
        self.icon = icon
    }
}
/// Categoria macro-evento nel ciclo di vita EviMail.
enum EventType: Hashable {
    case preparation    // Preparazione/attesa invio
    case sending        // Invio in corso
    case reading        // Apertura/lettura
    case decision       // Decisione sul contenuto
    case closing        //fine del monitoraggio
    
    /// Restituisce asset icona coerente con tipo e stato specifico.
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
    
    /// Restituisce colore UI coerente con tipo e stato specifico.
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
    
    /// Restituisce descrizione localizzata per tipo/stato evento.
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

/// Stato concreto associato a un `EventType`.
enum EventState: Hashable {
    case preparation(PreparationState)
    case sending(SendingState)
    case reading(ReadingState)
    case decision(DecisionState)
    case closing(ClosingState)
}

/// Sotto-stati della fase preparazione.
enum PreparationState: Hashable {
    case pending    // In attesa
    case ready      // Pronto
}

/// Sotto-stati della fase invio.
enum SendingState: Hashable {
    case sent       // Inviato
    case dispatched // Spedito
    case delivered  // Consegnato
    case failed     // Fallito
}

/// Sotto-stati della fase lettura.
enum ReadingState: Hashable {
    case waiting     //in attesa di lettura
    case opened     // Aperto
}

/// Sotto-stati della fase decisione contenuto.
enum DecisionState: Hashable {
    case contentWaiting    // In attesa di decisione
    case contentAccepted    // Contenuto accettato
    case contentRejected    // Contenuto rifiutato
}

/// Sotto-stati della fase chiusura tracking.
enum ClosingState: Hashable {
    case closed
}

extension EmailEvent {

    /// Timestamp breve per UI compatta.
    var timestampShort: String {
        timestampUTC.formatted(
            .dateTime
                .day(.twoDigits)
                .month(.twoDigits)
                .year(.twoDigits)
                .hour(.twoDigits(amPM: .omitted))
                .minute(.twoDigits)
        )
    }

    /// Timestamp esteso leggibile per dettaglio evento.
    var timestampReadable: String {
        timestampUTC.formatted(
            .dateTime
                .day()
                .month(.abbreviated)
                .year()
                .hour(.twoDigits(amPM: .omitted))
                .minute(.twoDigits)
        )
    }

    /// Timestamp relativo (es. "2h ago").
    var timestampRelative: String {
        timestampUTC.formatted(.relative(presentation: .named, unitsStyle: .abbreviated))
    }
}

