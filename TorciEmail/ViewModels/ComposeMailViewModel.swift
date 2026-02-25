//
//  EviMailComposeViewModel.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 13/02/26.
//

import Foundation
import Combine

// MARK: - EviMail Compose ViewModel
class ComposeMailViewModel: ObservableObject {

    private let emailRepository: EmailRepository

    // MARK: - Email Data
    @Published var toRecipients: [String] = []
    @Published var ccRecipients: [String] = []
    @Published var ccRecipientsNames: [String: String] = [:]
    @Published var recipientNames: [String: String] = [:]
    @Published var issuerName: String = "NamirialTest-LC"
    @Published var subject: String = ""
    @Published var body: String = ""
    @Published var fromEmail: String = "torci.ado@outlook.it"
    @Published var availableFromEmails: [String] = ["torci.ado@outlook.it"]

    // MARK: - UI State
    @Published var isSending: Bool = false
    @Published var errorMessage: String?

    // MARK: - Email Settings
    @Published var replyToAddress: String = ""
    @Published var certificationLevel: String = "Advanced"
    @Published var language: String = "en"
    @Published var affidavitLanguage: String = "en"
    @Published var removeSenderHeader: Bool = false

    // MARK: - UI State
    @Published var showCc: Bool = false
    @Published var showReplyTo: Bool = false

    // MARK: - Certification Tab
    @Published var appearance: String = "Certified"
    @Published var trackingUntil: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()

    // MARK: - Affidavit Steps
    // title  → mostrato nella UI
    // apiValue → inviato all'API (corrisponde ai valori della web app)
    @Published var affidavitSteps: [AffidavitStep] = [
        AffidavitStep(title: "Message Admission",               apiValue: "Submitted",          isEnabled: false),
        AffidavitStep(title: "Message Admission",               apiValue: "SubmittedAdvanced",  isAdvanced: true, isEnabled: true),
        AffidavitStep(title: "Transmission Vault",              apiValue: "TransmissionResult", isEnabled: true),
        AffidavitStep(title: "Delivery result",                 apiValue: "DeliveryResult",     isEnabled: true),
        AffidavitStep(title: "Message Opened",                  apiValue: "Read",               isEnabled: true),
        AffidavitStep(title: "Acceptance / Rejection Decision", apiValue: "Committed",          isEnabled: false),
        AffidavitStep(title: "Acceptance / Rejection Decision", apiValue: "CommittedAdvanced",  isAdvanced: true, isEnabled: true),
        AffidavitStep(title: "Process Finalize",                apiValue: "Closed",             isEnabled: false),
        AffidavitStep(title: "Process Finalize",                apiValue: "ClosedAdvanced",     isAdvanced: true, isEnabled: false),
        AffidavitStep(title: "Process Completion",              apiValue: "Complete",           isEnabled: true),
        AffidavitStep(title: "Process Completion",              apiValue: "CompleteAdvanced",   isAdvanced: true, isEnabled: false),
        AffidavitStep(title: "Request certifications",          apiValue: "OnDemand",           isEnabled: false),
        AffidavitStep(title: "Revision Fact",                   apiValue: "Event",              isEnabled: true),
        AffidavitStep(title: "Process Failure",                 apiValue: "Failed",             isEnabled: true),
    ]

    // MARK: - Agreement Settings
    @Published var agreementPossibilities: String = "Accept"
    @Published var allowReasons: Bool = false
    @Published var acceptReasons: [String] = []
    @Published var rejectReasons: [String] = []
    @Published var acceptReasonsRequired: Bool = false
    @Published var rejectReasonsRequired: Bool = false

    // MARK: - Advanced Tab (Custody Settings)
    @Published var showCustodyAccessControl: Bool = false
    @Published var custodyAccessControl: [String] = [
        "Anyone who knows the link",
        "Users of related websites (issuer/receiver)",
        "Challenge question/answer",
        "Request of random known data"
    ]
    @Published var accessControl: String = "Anyone who knows the link"
    @Published var custodyLTAEnabled: Bool = false
    @Published var notarialDepositEnabled: Bool = false
    @Published var notarialDepositURL: String = ""
    @Published var costCentreEnabled: Bool = false
    @Published var costCentre: String = "Namirial"
    @Published var showFutureImplementationAlert: Bool = true

    // MARK: - Constants
    let availableLanguages = ["en", "it"]
    let certificationLevels = ["Basic", "Advanced", "Qualified"]

    // MARK: - Validation
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    var canSend: Bool {
        guard !toRecipients.isEmpty else { return false }
        guard !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }

        let allRecipientsValid = toRecipients.allSatisfy { recipient in
            isValidEmail(extractEmail(from: recipient))
        }
        guard allRecipientsValid else { return false }

        if showReplyTo && !replyToAddress.trimmingCharacters(in: .whitespaces).isEmpty {
            guard isValidEmail(replyToAddress) else { return false }
        }

        return true
    }

    // MARK: - Helper
    private func extractEmail(from recipient: String) -> String {
        if let range = recipient.range(of: "<") {
            return String(recipient[..<range.lowerBound])
                .trimmingCharacters(in: .whitespaces)
        }
        return recipient.trimmingCharacters(in: .whitespaces)
    }

    var disclosureCanCollapse: Bool {
        ccRecipients.isEmpty
    }

    init(fromEmail: String = "", emailRepository: EmailRepository = EmailRepositoryImpl()) {
        self.fromEmail = fromEmail
        self.availableFromEmails = [fromEmail]
        self.emailRepository = emailRepository
    }

    // MARK: - Email Actions
    func sendEmail() async -> Bool {
        guard let draft = createEmailDraft() else {
            errorMessage = "Errore nella creazione della bozza"
            return false
        }

        isSending = true
        errorMessage = nil

        do {
            let eviId = try await emailRepository.sendEmail(draft)
            print("Email inviata con successo - EVI ID: \(eviId)")
            isSending = false
            return true

        } catch let error as RepositoryError {
            errorMessage = error.errorDescription
            print("Errore invio: \(error.errorDescription ?? "Unknown")")
            isSending = false
            return false
        } catch {
            errorMessage = "Errore sconosciuto durante l'invio"
            print("Unexpected error: \(error)")
            isSending = false
            return false
        }
    }

    // MARK: - Create EmailDraft
    func createEmailDraft() -> EmailDraft? {
        guard !toRecipients.isEmpty else {
            errorMessage = "Aggiungi almeno un destinatario"
            return nil
        }

        guard !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Inserisci un oggetto"
            return nil
        }

        guard !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Inserisci un corpo del messaggio"
            return nil
        }

        // Usa apiValue invece di title per inviare i valori corretti all'API
        let enabledAffidavits = affidavitSteps
            .filter { $0.isEnabled }
            .map { $0.apiValue }

        let options = EmailOptions(
            certificationLevel: certificationLevel,
            language: language,
            affidavitLanguage: affidavitLanguage,
            appearance: appearance,
            agreementPossibilities: agreementPossibilities,
            allowReasons: allowReasons,
            acceptReasons: acceptReasons,
            rejectReasons: rejectReasons,
            acceptReasonsRequired: acceptReasonsRequired,
            rejectReasonsRequired: rejectReasonsRequired,
            affidavitKinds: enabledAffidavits,
            pushNotificationUrl: notarialDepositEnabled ? notarialDepositURL : nil,
            costCentre: costCentreEnabled ? costCentre : nil
        )

        let firstRecipient = toRecipients.first!
        let firstRecipientEmail = extractEmail(from: firstRecipient)

        let carbonCopy: [CarbonCopyDraft]? = showCc && !ccRecipients.isEmpty ?
            ccRecipients.map { recipient in
                CarbonCopyDraft(
                    name: ccRecipientsNames[recipient] ?? "",
                    emailAddress: extractEmail(from: recipient)
                )
            } : nil

        return EmailDraft(
            subject: subject.trimmingCharacters(in: .whitespacesAndNewlines),
            body: body.trimmingCharacters(in: .whitespacesAndNewlines),
            issuerName: issuerName,
            recipientName: recipientNames[firstRecipient] ?? "",
            recipientEmail: firstRecipientEmail,
            replyTo: showReplyTo && !replyToAddress.isEmpty ? replyToAddress : nil,
            carbonCopy: carbonCopy,
            options: options,
            attachments: nil
        )
    }
}
