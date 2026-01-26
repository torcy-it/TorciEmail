//
//  EmailAttachment.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import Foundation

// MARK: - Email Attachment
struct EmailAttachment: Identifiable, Hashable, Codable {
    enum Kind: String, Hashable, Codable {
        case pdf
        case image
        case doc
        case zip
        case other
        
        // Initialize from MIME type
        init(mimeType: String) {
            switch mimeType.lowercased() {
            case let type where type.contains("pdf"):
                self = .pdf
            case let type where type.contains("image"):
                self = .image
            case let type where type.contains("word"), let type where type.contains("doc"):
                self = .doc
            case let type where type.contains("zip"):
                self = .zip
            default:
                self = .other
            }
        }
    }

    let id: UUID
    var name: String
    var sizeLabel: String
    var kind: Kind
    var hash: String?
    var rawData: String? // Store base64 data

    init(
        id: UUID = UUID(),
        name: String,
        sizeLabel: String,
        kind: Kind,
        hash: String? = nil,
        rawData: String? = nil
    ) {
        self.id = id
        self.name = name
        self.sizeLabel = sizeLabel
        self.kind = kind
        self.hash = hash
        self.rawData = rawData
    }
}