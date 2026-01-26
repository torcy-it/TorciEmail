//
//  EmailItem+Extensions.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import Foundation

// MARK: - Certificate Management
extension EmailItem {
    
    /// Add an EviMail affidavit to this email
    mutating func addEviMailAffidavit(_ affidavit: CertificateAffidavit) {
        affidavits.append(affidavit)
    }
    
    /// Get affidavits filtered by category
    func affidavits(forCategory category: CertificateCategory) -> [CertificateAffidavit] {
        affidavits.filter { $0.certificateType.category == category }
    }
    
    /// Get the latest affidavit of a specific type
    func latestAffidavit(ofType type: EviMailCertificateType) -> CertificateAffidavit? {
        affidavits
            .filter { $0.certificateType == type }
            .sorted { $0.timestamp > $1.timestamp }
            .first
    }
    
    @available(*, deprecated, renamed: "addEviMailAffidavit")
    mutating func addAffidavit(_ affidavit: CertificateAffidavit) {
        affidavits.append(affidavit)
    }
}