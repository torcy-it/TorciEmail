import SwiftUI
import UniformTypeIdentifiers

// MARK: - Main EviMail Compose View
/// Contenitore principale della composizione EviMail a tab.
struct EviMailComposeView: View {
    @StateObject private var viewModel: ComposeMailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: ComposeTab = .content
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    @State private var validationSymbol: String = ""
    @State private var sendTask: Task<Void, Never>? = nil
    @State private var showFileImporter: Bool = false

    /// Inizializza la compose con mittente pre-selezionato.
    init(fromEmail: String) {
        _viewModel = StateObject(wrappedValue: ComposeMailViewModel(fromEmail: fromEmail))
    }

    /// Gestisce tab di composizione, invio e selezione allegato da file system.
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ComposeTabBar(selectedTab: $selectedTab)

                    switch selectedTab {
                    case .content:       contentTab
                    case .certification: certificationTab
                    case .advanced:      advancedTab
                    case .preview:       previewTab
                    }
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("New EviMail")
            .navigationBarTitleDisplayMode(.large)
            .alert("", isPresented: $showValidationAlert) {
                Button("OK") { showValidationAlert = false }
            } message: {
                Label(validationMessage, systemImage: validationSymbol)
            }
            .alert("", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Label(viewModel.errorMessage ?? "", systemImage: "xmark.octagon")
            }
            .alert("Attachment Error", isPresented: Binding(
                get: { viewModel.uploadError != nil },
                set: { if !$0 { viewModel.uploadError = nil } }
            )) {
                Button("OK") { viewModel.uploadError = nil }
            } message: {
                Text(viewModel.uploadError ?? "")
            }
            .onDisappear {
                sendTask?.cancel()
                viewModel.isSending = false
                viewModel.errorMessage = nil
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if viewModel.toRecipients.isEmpty {
                            validationMessage = "Add at least one recipient"
                            validationSymbol = "person.crop.circle.badge.exclamationmark"
                            showValidationAlert = true
                        } else if viewModel.subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            validationMessage = "Subject cannot be empty"
                            validationSymbol = "text.badge.exclamationmark"
                            showValidationAlert = true
                        } else if viewModel.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            validationMessage = "Email body cannot be empty"
                            validationSymbol = "doc.badge.exclamationmark"
                            showValidationAlert = true
                        } else if viewModel.showReplyTo && !viewModel.replyToAddress.isEmpty && !viewModel.isValidEmail(viewModel.replyToAddress) {
                            validationMessage = "Reply-To address is not valid"
                            validationSymbol = "envelope.badge.exclamationmark"
                            showValidationAlert = true
                        } else {
                            sendTask = Task {
                                let success = await viewModel.submitEmailWithAttachment()
                                if success { dismiss() }
                            }
                        }
                    } label: {
                        if viewModel.isSending {
                            ProgressView()
                        } else {
                            Image(systemName: "paperplane")
                        }
                    }
                    .disabled(viewModel.isSending)
                }

                ToolbarItem(placement: .bottomBar) {
                    if selectedTab == .content {
                        Button("Attach Files", systemImage: "paperclip") {
                            showFileImporter = true
                        }
                    }
                }
                ToolbarSpacer(placement: .bottomBar)
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [
                    .pdf,
                    .image,
                    .jpeg,
                    .png,
                    .zip,
                    .data,
                    .item
                ],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        viewModel.selectAttachment(url: url)
                    }
                case .failure(let error):
                    viewModel.uploadError = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Content Tab
    private var contentTab: some View {
        ContentTabView(viewModel: viewModel)
    }

    // MARK: - Other Tabs
    private var certificationTab: some View {
        CertificationTabView(viewModel: viewModel)
    }

    private var advancedTab: some View {
        AdvancedTabView(viewModel: viewModel)
    }

    private var previewTab: some View {
        PreviewTabView(viewModel: viewModel)
    }
}
