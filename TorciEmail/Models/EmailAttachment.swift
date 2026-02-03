//
//  EmailAttachment.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//
import Foundation


struct EmailAttachment: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let sizeLabel: String
    let kind: Kind
    
    enum Kind: Hashable {
        case pdf, image, doc, zip, other
    }
}
