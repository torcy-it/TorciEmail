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
    // MARK: - Email Data (Arrays for multiple recipients)
    @Published var toRecipients: [String] = []
    @Published var ccRecipients: [String] = []
    @Published var recipientNames: [String: String] = [:] // email -> name mapping
    @Published var issuerName: String = "NamirialTest-LC"
    @Published var subject: String = ""
    @Published var body: String = ""
    
    // MARK: - Email Settings
    @Published var replyToAddress: String = ""
    @Published var certificationLevel: String = "Advanced (EU)"
    @Published var language: String = "en"
    @Published var affidavitLanguage: String = "en"
    @Published var removeSenderHeader: Bool = false
    
    // MARK: - UI State
    @Published var showCc: Bool = false
    @Published var showReplyTo: Bool = false
    @Published var isSending: Bool = false
    
    // MARK: - Certification Tab
    @Published var appearance: String = "Certified"
    @Published var trackingUntil: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()

    // MARK: - Affidavit Steps
    @Published var affidavitSteps: [AffidavitStep] = [
        AffidavitStep(title: "Message Admission",                    isEnabled: true),
        AffidavitStep(title: "Message Admission",     isAdvanced: true, isEnabled: true),
        AffidavitStep(title: "Transmission Vault",                   isEnabled: true),
        AffidavitStep(title: "Delivery result",                      isEnabled: true),
        AffidavitStep(title: "Message Opened",                       isEnabled: false),
        AffidavitStep(title: "Acceptance / Rejection Decision",      isEnabled: false),
        AffidavitStep(title: "Acceptance / Rejection Decision", isAdvanced: true, isEnabled: false),
        AffidavitStep(title: "Process Finalize",                     isEnabled: false),
        AffidavitStep(title: "Process Finalize",      isAdvanced: true, isEnabled: false),
        AffidavitStep(title: "Process Completion",                   isEnabled: false),
        AffidavitStep(title: "Process Completion",    isAdvanced: true, isEnabled: false),
        AffidavitStep(title: "Request certifications",               isEnabled: false),
        AffidavitStep(title: "Revision Fact",                        isEnabled: false),
        AffidavitStep(title: "Process Failure",                      isEnabled: false),
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
    @Published var showFutureImplementationAlert: Bool = true
    
    // MARK: - Constants
    let availableLanguages = ["en", "it"]
    let certificationLevels = ["Basic", "Advanced", "Qualified"]
    
    // MARK: - Create EmailDraft
    func createEmailDraft() -> [EmailDraft]? {
        // Validate required fields
        guard !toRecipients.isEmpty else {
            print("Error: At least one recipient is required")
            return nil
        }
        
        guard !subject.isEmpty else {
            print("Error: Subject is required")
            return nil
        }
        
        // Create email options
        let options = EmailOptions(
            certificationLevel: certificationLevel,
            language: language,
            affidavitLanguage: affidavitLanguage
        )
        
        // Create carbon copy if provided
        let carbonCopy: CarbonCopyDraft? = showCc && !ccRecipients.isEmpty ?
            CarbonCopyDraft(
                name: recipientNames[ccRecipients.first!] ?? "",
                emailAddress: ccRecipients.first!
            ) : nil
        
        // Create a draft for each recipient
        return toRecipients.map { recipientEmail in
            EmailDraft(
                subject: subject,
                body: body,
                issuerName: issuerName,
                recipientName: recipientNames[recipientEmail] ?? "",
                recipientEmail: recipientEmail,
                replyTo: showReplyTo && !replyToAddress.isEmpty ? replyToAddress : nil,
                carbonCopy: carbonCopy,
                options: options,
                attachments: nil
            )
        }
    }
    
    // MARK: - Email Actions
    func sendEmail() async -> Bool {
        guard let drafts = createEmailDraft() else {
            return false
        }
        
        isSending = true
        
        // TODO: Implement actual email sending with your repository
        print("Sending \(drafts.count) email(s)...")
        for draft in drafts {
            print("To: \(draft.recipientEmail)")
        }
        print("Subject: \(drafts.first?.subject ?? "")")
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        isSending = false
        return true
    }
    
    // MARK: - Validation
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var canSend: Bool {
        !toRecipients.isEmpty &&
        !subject.isEmpty &&
        !body.isEmpty &&
        toRecipients.allSatisfy { isValidEmail($0) }
    }
    
    var disclosureCanCollapse: Bool {
        ccRecipients.isEmpty
    }
}
