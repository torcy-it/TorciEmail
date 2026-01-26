//
//  EmailEvent.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 24/01/26.
//


//
//  EmailEvent.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import SwiftUI
import Foundation

// MARK: - Email Event
enum EmailEvent: String, CaseIterable, Codable {
    case sent
    case open
    case decision
}

// MARK: - Event States
enum SentEventState: String, CaseIterable, Codable {
    case waiting
    case sent
    case failed
}

enum OpenEventState: String, CaseIterable, Codable {
    case waiting
    case opened
}

enum DecisionEventState: String, CaseIterable, Codable {
    case waiting
    case accepted
    case rejected
}

enum EmailEventState: Codable, Hashable {
    case sent(SentEventState)
    case open(OpenEventState)
    case decision(DecisionEventState)
    
    enum CodingKeys: String, CodingKey {
        case type, value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "sent":
            let value = try container.decode(SentEventState.self, forKey: .value)
            self = .sent(value)
        case "open":
            let value = try container.decode(OpenEventState.self, forKey: .value)
            self = .open(value)
        case "decision":
            let value = try container.decode(DecisionEventState.self, forKey: .value)
            self = .decision(value)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .sent(let value):
            try container.encode("sent", forKey: .type)
            try container.encode(value, forKey: .value)
        case .open(let value):
            try container.encode("open", forKey: .type)
            try container.encode(value, forKey: .value)
        case .decision(let value):
            try container.encode("decision", forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
}

// MARK: - Email Event Item
struct EmailEventItem: Codable, Hashable {
    let event: EmailEvent
    let state: EmailEventState
    let timestampUTC: Date
    var affidavitId: String?
}

// MARK: - EmailEvent Extensions
extension EmailEvent {
    func title(for state: EmailEventState) -> String {
        switch state {
        case .sent(let sentState):
            switch sentState {
            case .waiting: return "WAITING"
            case .sent: return "SENT"
            case .failed: return "FAILED"
            }
        case .open(let openState):
            switch openState {
            case .waiting: return "WAITING"
            case .opened: return "OPENED"
            }
        case .decision(let decisionState):
            switch decisionState {
            case .waiting: return "WAITING"
            case .accepted: return "ACCEPTED"
            case .rejected: return "REJECTED"
            }
        }
    }
    
    func symbolName(for state: EmailEventState) -> String {
        switch state {
        case .sent(let sentState):
            switch sentState {
            case .waiting: return "IconWaitEnv"
            case .sent: return "IconSendEnv"
            case .failed: return "IconRejectedEnv"
            }
        case .open(let openState):
            switch openState {
            case .waiting: return "IconWaitOpenEnv"
            case .opened: return "IconOpenEnv"
            }
        case .decision(let decisionState):
            switch decisionState {
            case .waiting: return "IconContentWait"
            case .accepted: return "IconContentAcc"
            case .rejected: return "IconContentRej"
            }
        }
    }
    
    func tint(for state: EmailEventState) -> Color {
        switch state {
        case .sent(let sentState):
            switch sentState {
            case .waiting: return .gray
            case .sent: return .green
            case .failed: return .red
            }
        case .open(let openState):
            switch openState {
            case .waiting: return .gray
            case .opened: return .green
            }
        case .decision(let decisionState):
            switch decisionState {
            case .waiting: return .gray
            case .accepted: return .green
            case .rejected: return .red
            }
        }
    }
}