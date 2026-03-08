//
//  EmailAttachment.swift
//  CertfiedEmail
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
            let type = mimeType.lowercased()
            
            if type.contains("pdf") {
                return .pdf
            }
            if type.contains("image") {
                return .image
            }
            if type.contains("word") || type.contains("document") {
                return .doc
            }
            if type.contains("zip") || type.contains("compressed") {
                return .zip
            }
            return .other
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
