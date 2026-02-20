import SwiftUI

// MARK: - Main EviMail Compose View
struct EviMailComposeView: View {
    @StateObject private var viewModel = ComposeMailViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: ComposeTab = .content

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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            let success = await viewModel.sendEmail()
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isSending {
                            ProgressView()
                        } else {
                            Image(systemName: "paperplane")
                        }
                    }
                    .disabled(!viewModel.canSend || viewModel.isSending)
                }

                ToolbarItem(placement: .bottomBar) {
                    if selectedTab == .content {
                        Button("Attach Files", systemImage: "paperclip") {
                            // TODO: Implement file attachment
                        }
                    }
                }
                ToolbarSpacer(placement: .bottomBar)
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

// MARK: - Preview
#Preview {
    EviMailComposeView()
}


