//
//  ComposeMailViewModel.swift
//  CertfiedEmail
//
//  ViewModel MVVM della schermata di composizione EviMail.
//  Gestisce stato UI, validazione form, creazione bozza e invio.
//

import Foundation
import Combine

/// ViewModel principale della composizione email certificata.
final class ComposeMailViewModel: ObservableObject {

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
    
    // Gestione allegato singolo
    @Published var selectedAttachmentURL: URL?
    @Published var selectedAttachmentName: String?
    @Published var isUploading: Bool = false
    @Published var uploadError: String?

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
    
    /// Verifica il formato email con regex base.
    /// - Parameter email: Indirizzo da validare.
    /// - Returns: `true` se il formato è valido.
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    /// Indica se i campi minimi richiesti sono validi per l'invio.
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

    // MARK: - Supporto
    
    /// Estrae l'email da una stringa formattata tipo `Nome <email@domain>`.
    /// - Parameter recipient: Stringa destinatario.
    /// - Returns: Indirizzo email normalizzato.
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

    /// Crea il ViewModel con dipendenza repository iniettabile.
    /// - Parameters:
    ///   - fromEmail: Mittente iniziale selezionato.
    ///   - emailRepository: Implementazione repository (DI).
    init(fromEmail: String = "", emailRepository: EmailRepository = EmailRepositoryImpl()) {
        self.fromEmail = fromEmail
        self.availableFromEmails = [fromEmail]
        self.emailRepository = emailRepository
    }

    // MARK: - Email Actions
    
    /// Esegue l'invio standard senza allegati locali.
    /// - Returns: `true` se l'invio è andato a buon fine.
    func sendEmail() async -> Bool {
        guard let draft = createEmailDraft() else {
            errorMessage = "Error creating draft"
            return false
        }

        isSending = true
        errorMessage = nil
        defer { isSending = false }

        do {
            _ = try await emailRepository.sendEmail(draft)
            return true
        } catch let error as RepositoryError {
            errorMessage = error.errorDescription
            return false
        } catch {
            errorMessage = "Unknown error while sending"
            return false
        }
    }
    
    /// Punto di ingresso usato dalla UI. Se è presente un allegato usa l'endpoint dedicato,
    /// altrimenti esegue il flusso di invio standard.
    /// - Returns: `true` se l'invio è completato correttamente.
    func submitEmailWithAttachment() async -> Bool {
        guard let draft = createEmailDraft() else {
            errorMessage = "Error creating draft"
            return false
        }
        
        // Nessun allegato: fallback alla logica esistente
        guard let attachmentURL = selectedAttachmentURL else {
            return await sendEmail()
        }
        
        isSending = true
        isUploading = true
        uploadError = nil
        errorMessage = nil
        
        defer {
            isSending = false
            isUploading = false
        }
        
        do {
            _ = try await emailRepository.sendEmailWithAttachment(
                draft,
                fileURL: attachmentURL,
                fileName: selectedAttachmentName
            )
            return true
        } catch let error as RepositoryError {
            switch error {
            case .fileTooLarge, .unsupportedFileType:
                uploadError = error.errorDescription
            default:
                errorMessage = error.errorDescription
            }
            return false
        } catch {
            errorMessage = "Unknown error while sending"
            return false
        }
    }
    
    // MARK: - Supporto Allegati
    
    /// Memorizza il file selezionato per l'invio.
    /// - Parameters:
    ///   - url: URL locale del file.
    ///   - suggestedName: Nome mostrato in UI (opzionale).
    func selectAttachment(url: URL, suggestedName: String? = nil) {
        selectedAttachmentURL = url
        selectedAttachmentName = suggestedName ?? url.lastPathComponent
        uploadError = nil
    }
    
    /// Rimuove l'allegato corrente dalla bozza.
    func clearAttachment() {
        selectedAttachmentURL = nil
        selectedAttachmentName = nil
        uploadError = nil
    }

    // MARK: - Create EmailDraft
    
    /// Costruisce il modello `EmailDraft` dai campi correnti del form.
    /// - Returns: Bozza pronta per il repository, oppure `nil` in caso di validazione fallita.
    func createEmailDraft() -> EmailDraft? {
        guard !toRecipients.isEmpty else {
            errorMessage = "Add at least one recipient"
            return nil
        }

        guard !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Enter a subject"
            return nil
        }

        guard !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Enter a message body"
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
