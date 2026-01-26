//
//  CertificateMetadata.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import Foundation

// MARK: - Certificate Metadata
struct CertificateMetadata: Codable, Hashable {
    var recipientEmail: String?
    var transmissionStatus: String?
    var deliveryStatus: String?
    var readTimestamp: Date?
    var commitmentDecision: String?
    var errorMessage: String?
    var additionalNotes: String?
}