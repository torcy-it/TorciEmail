//
//  CertificateAffidavit.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 24/01/26.
//


//
//  CertificateAffidavit.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import Foundation

// MARK: - Certificate Affidavit
struct CertificateAffidavit: Identifiable, Hashable, Codable {
    let id: UUID
    let affidavitId: String
    let certificateType: EviMailCertificateType
    let timestamp: Date
    let downloadUrl: String?
    let status: AffidavitStatus
    var metadata: CertificateMetadata?
    var rawBytes: String? // Store base64 PDF data
    
    enum AffidavitStatus: String, Codable {
        case generated = "Generated"
        case downloaded = "Downloaded"
        case verified = "Verified"
        case archived = "Archived"
    }
    
    init(
        id: UUID = UUID(),
        affidavitId: String,
        certificateType: EviMailCertificateType,
        timestamp: Date,
        downloadUrl: String? = nil,
        status: AffidavitStatus = .generated,
        metadata: CertificateMetadata? = nil,
        rawBytes: String? = nil
    ) {
        self.id = id
        self.affidavitId = affidavitId
        self.certificateType = certificateType
        self.timestamp = timestamp
        self.downloadUrl = downloadUrl
        self.status = status
        self.metadata = metadata
        self.rawBytes = rawBytes
    }
}