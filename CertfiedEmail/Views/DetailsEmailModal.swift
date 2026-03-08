//
//  DetailsEmailModal.swift
//  CertfiedEmail
//
//  Modale SwiftUI di dettaglio EviMail.
//  Mostra metadati funzionali/tecnici e timeline informativa.
//

import SwiftUI

struct DetailsEmailModal: View {
    @Binding var showDetailsModal: Bool
    let email: EmailItem
    @EnvironmentObject var mailVm: MailboxViewModel
    @State private var shareItems: [URL] = []
    @State private var showShareSheet = false
    @State private var exportError: String?
    
    /// Mostra il dettaglio esteso della email selezionata.
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    
                    // SECTION: GENERAL INFORMATION
                    DetailSection(title: "General Information") {
                        DetailRow(label: "Universal Locator", value: email.id)
                        DetailRow(label: "Proof Type", value: "MOCKUP")
                        DetailRow(label: "State", value: email.status.title, badge: email.status)
                        DetailRow(label: "Result", value: email.outcome ?? "IN PROGRESS")
                    }
                    
                    // SECTION: SENDER AND RECIPIENTS
                    DetailSection(title: "Sender, Issuer and Recipients") {
                        DetailRow(label: "Issuer", value: email.issuer.emailAddress)
                        DetailRow(label: "Sender", value: email.sender.emailAddress)
                        DetailRow(label: "Recipient", value: email.recipient.emailAddress)
                        
                        if !email.carbonCopy.isEmpty {
                            DetailRow(label: "Carbon Copy Recipients", value: email.carbonCopy.formatted)
                        }
                    }
                    
                    // SECTION: CONTENT
                    DetailSection(title: "Content") {
                        DetailRow(label: "Subject", value: email.emailObject)
                        DetailRow(label: "Body", value: email.bodyPlainText, isMultiline: true)
                    }
                    
                    // SECTION: TIMELINE
                    if hasTimelineData {
                        DetailSection(title: "Timeline") {
                            DetailRow(label: "Source Channel", value: email.sourceChannel ?? "Api")
                            
                            if let creationDate = email.creationDate {
                                DetailRow(label: "Creation Date", value: creationDate)
                            }
                            if let admissionDate = email.admissionDate {
                                DetailRow(label: "Admission Date", value: admissionDate)
                            }
                            if let dispatchedDate = email.dispatchedDate {
                                DetailRow(label: "Dispatch Date", value: dispatchedDate)
                            }
                            if let openedDate = email.openedDate {
                                DetailRow(label: "Opening Date", value: openedDate)
                            }
                            if let repliedDate = email.repliedDate {
                                DetailRow(label: "Replied On", value: repliedDate)
                            }
                            if let expirationDate = email.expirationDate {
                                DetailRow(label: "Monitoring End Date", value: expirationDate)
                            }
                        }
                    }
                    
                    // SECTION: CERTIFICATION
                    DetailSection(title: "Certification") {
                        DetailRow(label: "Online Retention Period", value: email.retentionPeriodFormatted)
                        DetailRow(label: "Certification Level", value: email.certificationLevel ?? "Standard")
                        DetailRow(label: "Affidavit Profile", value: "MOCKUP")
                        
                        if let signatureNotice = email.signatureNotice {
                            DetailRow(label: "Receipt Notice Signature", value: signatureNotice)
                        } else {
                            DetailRow(
                                label: "Receipt Notice Signature",
                                value: "MOCKUP"
                            )
                        }
                    }
                    
                    // SECTION: OPTIONS
                    DetailSection(title: "Options") {
                        DetailRow(
                            label: "Requires Captcha",
                            value: email.requiresCaptcha ? "Yes - Visual verification required" : "Not required"
                        )
                        DetailRow(
                            label: "Agreement Possibility",
                            value: email.allowsAgreement ? "Accept or reject" : "Not available"
                        )
                        DetailRow(
                            label: "Comments Allowed",
                            value: email.commentsAllowed ? "Comments are allowed" : "Not allowed"
                        )
    
                        if let accessControl = email.accessControl {
                            DetailRow(label: "Access Control", value: accessControl)
                        } else {
                            DetailRow(
                                label: "Access Control",
                                value: "Not specified"
                            )
                        }
                    }
                    
                    // SECTION: TECHNICAL DETAILS
                    DetailSection(title: "Technical Details") {
                        DetailRow(label: "Language", value: email.language)
                        DetailRow(label: "Layout", value: email.aspect)
                        
                        if let totalSize = email.totalSize {
                            DetailRow(label: "Total Size with Attachments", value: formatBytes(totalSize))
                        }
                        if let contentSize = email.contentSize {
                            DetailRow(label: "Content Size", value: formatBytes(contentSize))
                        }
                    }
                
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDetailsModal = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Details")
                        .font(.system(size: 17, weight: .semibold))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        exportDetailsPayload()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: shareItems)
            }
            .alert("Error", isPresented: .constant(exportError != nil)) {
                Button("OK") { exportError = nil }
            } message: {
                Text(exportError ?? "")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasTimelineData: Bool {
        email.sourceChannel != nil ||
        email.creationDate != nil ||
        email.admissionDate != nil ||
        email.dispatchedDate != nil ||
        email.openedDate != nil ||
        email.repliedDate != nil ||
        email.expirationDate != nil
    }
    
    // MARK: - Helper Methods
    
    /// Converte una dimensione in byte in una stringa leggibile.
    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    /// Esporta un riepilogo testuale dei dettagli email e apre la share sheet.
    private func exportDetailsPayload() {
        let content = """
        Email ID: \(email.id)
        Date: \(email.date)
        Status: \(email.status.title)
        
        Issuer: \(email.issuer.formatted)
        Sender: \(email.sender.formatted)
        Recipient: \(email.recipient.formatted)
        Carbon Copy: \(email.carbonCopy.formatted)
        
        Subject: \(email.emailObject)
        
        Body:
        \(email.bodyPlainText)
        """
        
        let safeId = email.id.replacingOccurrences(of: "/", with: "-")
        let fileName = "email-details-\(safeId).txt"
        
        do {
            let url = try mailVm.exportTextFile(content: content, fileName: fileName)
            shareItems = [url]
            showShareSheet = true
        } catch let error as RepositoryError {
            exportError = error.errorDescription
        } catch {
            exportError = "Error while exporting details"
        }
    }
}

// MARK: - Detail Section
struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let label: String
    let value: String
    var badge: EmailStatus? = nil
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            if let badge = badge {
                HStack {
                    Text(value)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(badge.badgeBackground.opacity(0.3))
                )
            } else {
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .lineLimit(isMultiline ? nil : 3)
                    .fixedSize(horizontal: false, vertical: isMultiline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


