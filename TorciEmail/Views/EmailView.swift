//
//  SelectRow.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 21/01/26.
//


import SwiftUI

struct EmailView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var mailVm: MailboxViewModel
    
    @State private var currentEmail: EmailItem
    @State private var isLoadingDetails = false
    @State private var detailsError: String?
    @State private var showDetailsModal = false
    @State private var showCertificatesModal = false

    // MARK: - Init
    
    init(email: EmailItem) {
        _currentEmail = State(initialValue: email)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    header

                    Divider().opacity(0.18)
                    
                    subject
                    
                    bodyCard
                    
                    if currentEmail.attachments.isEmpty { EmptyView() } else {
                        attachmentsCard
                    }

                    Spacer(minLength: 28)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
            }
            .modifier(ScrollEdgeTuning())
            
    
            if isLoadingDetails {
                loadingOverlay
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Email Details", systemImage: "info.circle") {
                    showDetailsModal.toggle()
                }
            }

            ToolbarItem(placement: .bottomBar) {
                Button("Certificates Details", systemImage: "checkmark.seal.text.page") {
                    showCertificatesModal.toggle()
                }
            }

            ToolbarSpacer(.flexible, placement: .bottomBar)

            ToolbarItem(placement: .bottomBar) {
                Button("Download Content Email", systemImage: "square.and.arrow.down") { }
            }
        }
        .sheet(isPresented: $showDetailsModal) {
            DetailsEmailModal(showDetailsModal: $showDetailsModal, email: currentEmail)
        }
        .sheet(isPresented: $showCertificatesModal) {
            CertificateEmailModal(showCertificatesModal: $showCertificatesModal, email: currentEmail)
        }
        .task {
       
            await loadEmailDetails()
        }
        .refreshable {
        
            await loadEmailDetails()
        }
        .alert("Error", isPresented: .constant(detailsError != nil)) {
            Button("OK") {
                detailsError = nil
            }
        } message: {
            if let error = detailsError {
                Text(error)
            }
        }
    }
    
    // MARK: - Load Email Details
    
    private func loadEmailDetails() async {
        guard !isLoadingDetails else { return }
        
        isLoadingDetails = true
        detailsError = nil
        
        do {
            let detailedEmail = try await mailVm.getEmailDetails(id: currentEmail.id)
            currentEmail = detailedEmail
        } catch let error as RepositoryError {
            detailsError = error.errorDescription
        } catch {
            detailsError = "Errore nel caricamento dei dettagli"
        }
        
        isLoadingDetails = false
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)
                
                Text("Loading details...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
        .transition(.opacity)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(currentEmail.senderName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Spacer()

                    Text(currentEmail.date)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    infoRow(label: "To", value: recipientLine(for: currentEmail))
                    infoRow(label: "Cc", value: carbonCopyLine(for: currentEmail))
                }
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 26, alignment: .leading)

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer()
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.black.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.black.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var subject: some View {
        Text(currentEmail.emailObject)
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 2)
    }
    
    private var attachmentsCard: some View {
        Group {
            if currentEmail.attachments.isEmpty {
                EmptyView()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "paperclip")
                            .foregroundStyle(.secondary)

                        Text("Attachments")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)

                        Text("• \(currentEmail.attachments.count)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button("View all") {
                            // TODO: sheet/push con lista completa
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 10
                    ) {
                        ForEach(currentEmail.attachments) { att in
                            attachmentTile(att)
                        }
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.black.opacity(0.035))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.black.opacity(0.08), lineWidth: 1)
                        )
                )
            }
        }
    }

    private func attachmentTile(_ att: EmailAttachment) -> some View {
        Button {
            
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.black.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.black.opacity(0.10), lineWidth: 1)
                        )
                        .frame(width: 42, height: 42)

                    Image(systemName: attachmentIcon(for: att.kind))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.55))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(att.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(att.sizeLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.black.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.black.opacity(0.08), lineWidth: 1)
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func attachmentIcon(for kind: EmailAttachment.Kind) -> String {
        switch kind {
        case .pdf: return "doc.richtext"
        case .image: return "photo"
        case .doc: return "doc"
        case .zip: return "doc.zipper"
        case .other: return "doc"
        }
    }

    private var bodyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Message")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(bodyText(for: currentEmail))
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(.primary.opacity(0.85))
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.black.opacity(0.035))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.black.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Helper Functions

private func recipientLine(for email: EmailItem) -> String {
    let cleaned = email.senderName
        .lowercased()
        .replacingOccurrences(of: " ", with: "")
    return "\(cleaned)@example.com"
}

private func carbonCopyLine(for email: EmailItem) -> String {
    guard !email.carbonCopy.isEmpty else { return "n/d" }
    return email.carbonCopyFormatted
}

private func bodyText(for email: EmailItem) -> String {
    email.emailDescription + "\n\n" + email.emailDescription
}
