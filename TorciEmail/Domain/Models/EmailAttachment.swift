//
//  EmailAttachment.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//

import Foundation

struct EmailAttachment: Identifiable, Hashable {
    let id: String
    let name: String
    let filename: String
    let size: Int?  // In bytes
    let mimeType: String
    let hash: String?
    let kind: Kind
    /// Dati base64 dell'allegato (se presenti nella risposta dettagliata)
    let base64Data: String?
    
    enum Kind: Hashable {
        case pdf, image, doc, zip, other
        
        
        static func from(mimeType: String) -> Kind {
            switch mimeType.lowercased() {
            case let type where type.contains("pdf"):
                return .pdf
            case let type where type.contains("image"):
                return .image
            case let type where type.contains("word"), let type where type.contains("document"):
                return .doc
            case let type where type.contains("zip"), let type where type.contains("compressed"):
                return .zip
            default:
                return .other
            }
        }
    }
    
 
    var sizeFormatted: String {
        guard let size = size else { return "Unknown size" }
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
    
   
    var sizeLabel: String {
        sizeFormatted
    }
}
