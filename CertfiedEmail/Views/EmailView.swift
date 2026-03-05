//
//  EmailView.swift
//  CertfiedEmail
//
//  Vista di dettaglio di una EviMail.
//  Mostra contenuto, metadati, allegati e apre anteprima locale dei file scaricati.
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
    @State private var attachmentDownloadError: String?
    @State private var previewURL: URL?

    // MARK: - Init
    
    /// Inizializza la vista con l'email selezionata dalla lista.
    /// - Parameter email: Modello email iniziale da dettagliare.
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
        .sheet(item: previewItemBinding) { item in
            FilePreviewSheet(url: item.url)
        }
        .task {
       
            await loadEmailDetails()
        }
        .refreshable {
        
            await loadEmailDetails()
        }
        .alert("Error", isPresented: .constant(detailsError != nil || attachmentDownloadError != nil)) {
            Button("OK") {
                detailsError = nil
                attachmentDownloadError = nil
            }
        } message: {
            if let error = detailsError ?? attachmentDownloadError {
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
            detailsError = "Error loading details"
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
                    Text("Issuer and Recipient")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Spacer()

                    Text(currentEmail.date)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    infoRow(label: "Issuer", value: currentEmail.issuer.emailAddress)
                    infoRow(label: "From", value: currentEmail.sender.emailAddress)
                    infoRow(label: "To", value: currentEmail.recipient.emailAddress)
                    infoRow(label: "Cc", value: currentEmail.carbonCopy.formatted)
                }
            }
        }
    }

    func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)
                .padding(.top, 2)

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .truncationMode(.tail)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 9)
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

                        Button("View all") { }
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
            Task {
                await handleAttachmentTap(att)
            }
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
    
    private func handleAttachmentTap(_ att: EmailAttachment) async {
        do {
            let url = try await mailVm.downloadAttachment(att)
            previewURL = url
        } catch let error as RepositoryError {
            attachmentDownloadError = error.errorDescription
        } catch {
            attachmentDownloadError = "Error downloading attachment"
        }
    }
    
    private var previewItemBinding: Binding<PreviewItem?> {
        Binding<PreviewItem?>(
            get: {
                guard let previewURL else { return nil }
                return PreviewItem(url: previewURL)
            },
            set: { newValue in
                previewURL = newValue?.url
            }
        )
    }

    private var bodyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Message")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(currentEmail.bodyPlainText)
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

private struct PreviewItem: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

