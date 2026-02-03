//
//  EmailEvent.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//
import Foundation
import SwiftUI

struct EmailEvent: Hashable {
    let event: EventType
    let state: EventState
    let timestampUTC: Date
}

enum EventType: Hashable {
    case sent, open, decision
    
    func symbolName(for state: EventState) -> String {
        switch (self, state) {
        case (.sent, .sent(.sent)):
            return "paperplane.fill"
        case (.sent, .sent(.dispatched)):
            return "shippingbox.fill"
        case (.sent, .sent(.delivered)):
            return "checkmark.circle.fill"
        case (.open, .open(.opened)):
            return "envelope.open.fill"
        case (.decision, .decision(.accepted)):
            return "hand.thumbsup.fill"
        case (.decision, .decision(.waiting)):
            return "clock.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    func tint(for state: EventState) -> Color {
        switch (self, state) {
        case (.sent, .sent(.sent)):
            return .blue
        case (.sent, .sent(.dispatched)):
            return .orange
        case (.sent, .sent(.delivered)):
            return .green
        case (.open, .open(.opened)):
            return .purple
        case (.decision, .decision(.accepted)):
            return .green
        case (.decision, .decision(.waiting)):
            return .gray
        default:
            return .secondary
        }
    }
}

enum EventState: Hashable {
    case sent(SentState)
    case open(OpenState)
    case decision(DecisionState)
}

enum SentState: Hashable {
    case sent, dispatched, delivered
}

enum OpenState: Hashable {
    case opened
}

enum DecisionState: Hashable {
    case accepted, waiting
}
