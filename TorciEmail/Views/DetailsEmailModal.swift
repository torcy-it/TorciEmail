//
//  DetailsEmailView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 04/02/26.
//

import SwiftUI

struct DetailsEmailModal: View {
    @Binding var showDetailsModal: Bool
    let email: EmailItem
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    
                    // SECTION: GENERAL INFORMATION
                    DetailSection(title: "General Information") {
                        DetailRow(label: "Universal Locator", value: email.id)
                        DetailRow(label: "Proof Type", value: "EmailMessage - Sending content with certification and delivery confirmation")
                        DetailRow(label: "State", value: email.status.title, badge: email.status)
                        DetailRow(label: "Result", value: email.status.isFinal ? "COMPLETED" : "NONE")
                    }
                    
                    // SECTION: SENDER AND RECIPIENTS
                    DetailSection(title: "Sender and Recipients") {
                        DetailRow(label: "Sender Address", value: "\(email.senderName) <\(email.senderEmail)>")
                        DetailRow(label: "Sender Name or Company Name", value: email.senderName)
                        DetailRow(label: "Recipient(s)", value: "\(email.recipientName) <\(email.recipientEmail)>")
                        
                        if !email.carbonCopy.isEmpty {
                            DetailRow(label: "Carbon Copy Recipients", value: email.carbonCopyFormatted)
                        }
                    }
                    
                    // SECTION: CONTENT
                    DetailSection(title: "Content") {
                        DetailRow(label: "Subject", value: email.emailObject)
                        DetailRow(label: "Message Body", value: email.emailDescription, isMultiline: true)
                    }
                    
                    // SECTION: TIMELINE
                    if hasTimelineData {
                        DetailSection(title: "Timeline") {
                            if let sourceChannel = email.sourceChannel {
                                DetailRow(label: "Source Channel", value: sourceChannel)
                            }
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
                        
                        if !email.certificationLevel.isEmpty {
                            DetailRow(label: "Certification Level", value: email.certificationLevelFormatted)
                        }
                        
                        DetailRow(label: "Affidavit Profile", value: "Content in creation and closing")
                        DetailRow(
                            label: "Receipt Notice Signature",
                            value: email.signatureNotice ?? "The operation is performed if the message reference or locator is known"
                        )
                    }
                    
                    // SECTION: OPTIONS
                    DetailSection(title: "Options") {
                        DetailRow(label: "Requires Captcha", value: email.requiresCaptcha ? "Yes" : "Not required")
                        DetailRow(label: "Agreement Possibility", value: email.allowsAgreement ? "Accept or reject" : "Not available")
                        DetailRow(label: "Comments Allowed", value: email.commentsAllowed ? "Comments are allowed" : "Not allowed")
                        DetailRow(
                            label: "Access Control",
                            value: email.accessControl ?? "The operation is performed if a casual question is correctly answered for known information such as the recipient's email address"
                        )
                    }
                    
                    // SECTION: TECHNICAL DETAILS
                    DetailSection(title: "Technical Details") {
                        DetailRow(label: "Language", value: email.language)
                        DetailRow(label: "Aspect", value: email.aspect)
                        
                        if let totalSize = email.totalSize {
                            DetailRow(label: "Total Size with Attachments", value: "\(totalSize) bytes")
                        }
                        if let contentSize = email.contentSize {
                            DetailRow(label: "Content Size", value: "\(contentSize) bytes")
                        }
                    }
                    
                    // SECTION: ATTACHMENTS
                    if email.hasAttachments {
                        DetailSection(title: "Attachments (\(email.attachmentCount))") {
                            ForEach(email.attachments, id: \.id) { attachment in
                                AttachmentRow(attachment: attachment)
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button ("Exit", systemImage: "xmark"){
                        showDetailsModal = false
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button ("Download Details", systemImage: "square.and.arrow.down"){
                        // TODO: Download details
                        print("Download details")
                    }
                }
            }
            .navigationTitle("Details")
            .toolbarTitleDisplayMode(.inline)
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
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
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
                    .lineLimit(isMultiline ? nil : 2)
                    .fixedSize(horizontal: false, vertical: isMultiline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Attachment Row
struct AttachmentRow: View {
    let attachment: EmailAttachment
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.fill")
                .font(.system(size: 24))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(attachment.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(attachment.sizeLabel)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                print("Download: \(attachment.name)")
            } label: {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Preview
#Preview {
    DetailsEmailModal(
        showDetailsModal: .constant(true),
        email: .example
    )
}

