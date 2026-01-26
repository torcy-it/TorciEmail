//
//  EmailItem.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import Foundation

// MARK: - Email Item
struct EmailItem: Identifiable, Hashable, Codable {
    let id: UUID
    let senderName: String
    let emailObject: String
    let emailDescription: String
    let date: String
    let status: EmailStatus
    var events: [EmailEventItem]
    var attachments: [EmailAttachment]
    
    // Certificate fields
    var certificateProfile: CertificateProfile?
    var affidavits: [CertificateAffidavit]
    var evidence: EvidenceDetails?
    var lifetimeExpiresAt: Date?
    
    // API metadata
    var apiUniqueId: String?
    var lookupKey: String?
    var acceptOrRejectComments: String?
    
    init(
        id: UUID = UUID(),
        senderName: String,
        emailObject: String,
        emailDescription: String,
        date: String,
        status: EmailStatus,
        events: [EmailEventItem],
        attachments: [EmailAttachment] = [],
        certificateProfile: CertificateProfile? = nil,
        affidavits: [CertificateAffidavit] = [],
        evidence: EvidenceDetails? = nil,
        lifetimeExpiresAt: Date? = nil,
        apiUniqueId: String? = nil,
        lookupKey: String? = nil,
        acceptOrRejectComments: String? = nil
    ) {
        self.id = id
        self.senderName = senderName
        self.emailObject = emailObject
        self.emailDescription = emailDescription
        self.date = date
        self.status = status
        self.events = events
        self.attachments = attachments
        self.certificateProfile = certificateProfile
        self.affidavits = affidavits
        self.evidence = evidence
        self.lifetimeExpiresAt = lifetimeExpiresAt
        self.apiUniqueId = apiUniqueId
        self.lookupKey = lookupKey
        self.acceptOrRejectComments = acceptOrRejectComments
    }
    
    // MARK: - Computed Properties
    
    var isAdvancedCertification: Bool {
        certificateProfile?.level == .advanced ||
        certificateProfile?.level == .allEvent ||
        certificateProfile?.level == .allEventPlusClose
    }
    
    var eventsProgress: EmailEventsProgress {
        status.eventsProgress
    }
    
    var hasCertificates: Bool {
        !affidavits.isEmpty
    }
    
    var certificateCount: Int {
        affidavits.count
    }
    
    var hasAdvancedCertificates: Bool {
        affidavits.contains { $0.certificateType.isAdvanced }
    }
    
    var certificatesByCategory: [CertificateCategory: [CertificateAffidavit]] {
        Dictionary(grouping: affidavits) { $0.certificateType.category }
    }
    
    // MARK: - Hashable & Equatable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: EmailItem, rhs: EmailItem) -> Bool {
        lhs.id == rhs.id
    }
}
