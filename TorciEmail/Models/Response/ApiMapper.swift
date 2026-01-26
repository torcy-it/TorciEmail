//
//  APIMapper.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import Foundation

// MARK: - API to Domain Mappers

extension CertificateAffidavit {
    /// Initialize CertificateAffidavit from API affidavit
    init?(from apiAffidavit: APIAffidavit) {
        guard let certType = EviMailCertificateType(apiKind: apiAffidavit.kind) else {
            return nil
        }
        
        let dateFormatter = ISO8601DateFormatter()
        let timestamp = dateFormatter.date(from: apiAffidavit.date) ?? Date()
        
        self.init(
            affidavitId: apiAffidavit.uniqueId,
            certificateType: certType,
            timestamp: timestamp,
            downloadUrl: nil,
            status: .generated,
            metadata: CertificateMetadata(additionalNotes: apiAffidavit.description),
            rawBytes: apiAffidavit.bytes
        )
    }
}

extension EmailAttachment {
    /// Initialize EmailAttachment from API attachment
    init(from apiAttachment: APIAttachment) {
        self.init(
            name: apiAttachment.fileName,
            sizeLabel: "Unknown", // Size not provided in API
            kind: Kind(mimeType: apiAttachment.mimeType),
            hash: apiAttachment.hash,
            rawData: apiAttachment.data
        )
    }
}

extension EvidenceDetails {
    /// Initialize EvidenceDetails from API result
    init(from apiResult: EviMailResult) {
        self.init(
            universalLocator: apiResult.uniqueId,
            typeOfEvidence: "EviMail",
            status: apiResult.state,
            outcome: apiResult.outcome,
            senderAddress: apiResult.issuer.emailAddress,
            senderNameOrCompany: apiResult.issuer.legalName ?? "",
            recipients: apiResult.recipient.emailAddress,
            otherRecipients: apiResult.carbonCopy?.map { $0.emailAddress }.joined(separator: ", ") ?? "",
            sourceChannel: apiResult.sourceChannel ?? "",
            dateOfCreation: apiResult.creationDate,
            onlineCustodyYears: "\(apiResult.onlineRetentionPeriod ?? 0)",
            affidavitsProfile: apiResult.affidavitKinds?.joined(separator: ", ") ?? ""
        )
    }
}

// MARK: - EmailItem API Mapping
extension EmailItem {
    /// Initialize EmailItem from API result
    init(from apiResult: EviMailResult) {
        let status = EmailStatus(apiState: apiResult.state) ?? .new
        let dateFormatter = ISO8601DateFormatter()
        let creationDate = dateFormatter.date(from: apiResult.creationDate) ?? Date()
        
        // Convert affidavits
        let affidavits = apiResult.affidavits.compactMap { CertificateAffidavit(from: $0) }
        
        // Convert attachments
        let attachments = apiResult.attachments.map { EmailAttachment(from: $0) }
        
        // Generate events from affidavits and status
        let events = EmailItem.generateEvents(from: apiResult, affidavits: affidavits)
        
        // Determine certificate profile
        let certProfile = EmailItem.determineCertificateProfile(from: apiResult)
        
        // Calculate lifetime expiration
        var lifetimeExpiration: Date?
        if let ttl = apiResult.timeToLive {
            lifetimeExpiration = creationDate.addingTimeInterval(TimeInterval(ttl * 60))
        }
        
        self.init(
            senderName: apiResult.issuer.legalName ?? apiResult.issuer.emailAddress,
            emailObject: apiResult.subject,
            emailDescription: apiResult.body.stripHTML(),
            date: DateFormatter.shortDate.string(from: creationDate),
            status: status,
            events: events,
            attachments: attachments,
            certificateProfile: certProfile,
            affidavits: affidavits,
            evidence: EvidenceDetails(from: apiResult),
            lifetimeExpiresAt: lifetimeExpiration,
            apiUniqueId: apiResult.uniqueId,
            lookupKey: apiResult.lookupKey,
            acceptOrRejectComments: apiResult.acceptOrRejectComments
        )
    }
    
    /// Generate events from API data and affidavits
    static func generateEvents(
        from apiResult: EviMailResult,
        affidavits: [CertificateAffidavit]
    ) -> [EmailEventItem] {
        var events: [EmailEventItem] = []
        
        // Sent event
        if let sentAffidavit = affidavits.first(where: { 
            $0.certificateType == .transmissionResult 
        }) {
            let state: EmailEventState = apiResult.outcome.lowercased().contains("failed") 
                ? .sent(.failed) 
                : .sent(.sent)
            events.append(EmailEventItem(
                event: .sent,
                state: state,
                timestampUTC: sentAffidavit.timestamp,
                affidavitId: sentAffidavit.affidavitId
            ))
        }
        
        // Open event
        if let readAffidavit = affidavits.first(where: { 
            $0.certificateType == .read 
        }) {
            events.append(EmailEventItem(
                event: .open,
                state: .open(.opened),
                timestampUTC: readAffidavit.timestamp,
                affidavitId: readAffidavit.affidavitId
            ))
        }
        
        // Decision event
        if let committedAffidavit = affidavits.first(where: { 
            $0.certificateType == .committed || $0.certificateType == .committedAdvanced 
        }) {
            let isAccepted = apiResult.acceptOrRejectComments?.lowercased().contains("reject") == false
            let decisionState: DecisionEventState = isAccepted ? .accepted : .rejected
            events.append(EmailEventItem(
                event: .decision,
                state: .decision(decisionState),
                timestampUTC: committedAffidavit.timestamp,
                affidavitId: committedAffidavit.affidavitId
            ))
        }
        
        return events
    }
    
    /// Determine certificate profile from affidavit kinds
    static func determineCertificateProfile(
        from apiResult: EviMailResult
    ) -> CertificateProfile? {
        guard let kinds = apiResult.affidavitKinds, !kinds.isEmpty else { 
            return nil 
        }
        
        let hasAdvanced = kinds.contains { $0.contains("Advanced") }
        let hasAllEvents = kinds.count > 5
        let hasClose = kinds.contains { $0.contains("Closed") }
        
        let level: CertificateProfile.CertificationLevel
        if hasAllEvents && hasClose {
            level = .allEventPlusClose
        } else if hasAllEvents {
            level = .allEvent
        } else if hasAdvanced {
            level = .advanced
        } else {
            level = .standard
        }
        
        return CertificateProfile(
            level: level,
            features: kinds,
            deliveryMode: nil
        )
    }
}