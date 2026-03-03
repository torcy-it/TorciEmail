//
//  PreviewTabView.swift
//  CertfiedEmail
//
//  Tab anteprima composizione.
//  Mostra un riepilogo read-only dei dati inseriti nella bozza.
//

import SwiftUI

// MARK: - Preview Tab View
/// Vista di anteprima completa della bozza email.
struct PreviewTabView: View {
    @ObservedObject var viewModel: ComposeMailViewModel

    /// Rende il riepilogo per sezioni di contenuto/certificazione/impostazioni.
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: - Email Content Section
                SectionView(title: "Email Content") {
                    PreviewRow(label: "To", value: viewModel.toRecipients.isEmpty ? "—" : viewModel.toRecipients.joined(separator: ", "))
                    PreviewRow(label: "Cc", value: viewModel.ccRecipients.isEmpty ? "—" : viewModel.ccRecipients.joined(separator: ", "))
                    PreviewRow(label: "From", value: viewModel.fromEmail)
                    PreviewRow(label: "Issuer Name", value: viewModel.issuerName.isEmpty ? "—" : viewModel.issuerName)
                    PreviewRow(label: "Subject", value: viewModel.subject.isEmpty ? "—" : viewModel.subject)
                    PreviewRow(label: "Body", value: viewModel.body.isEmpty ? "—" : viewModel.body)
                    PreviewRow(label: "Reply-To", value: viewModel.showReplyTo && !viewModel.replyToAddress.isEmpty ? viewModel.replyToAddress : "Not set")
                    PreviewRow(label: "Language", value: viewModel.language.uppercased())
                    PreviewRow(label: "Remove Sender Header", value: viewModel.removeSenderHeader ? "Yes" : "No", showDivider: false)
                }
                
                // MARK: - Certification Section
                SectionView(title: "Email Certification") {
                    PreviewRow(label: "Certification Level", value: viewModel.certificationLevel)
                    PreviewRow(label: "Affidavit Language", value: viewModel.affidavitLanguage == "en" ? "English" : "Italian")
                    PreviewRow(label: "Appearance", value: viewModel.appearance)
                    PreviewRow(label: "Tracking Until", value: formatDate(viewModel.trackingUntil))
                    
                    let enabledSteps = viewModel.affidavitSteps.filter { $0.isEnabled }.map { $0.title }
                    PreviewRow(label: "Enabled Steps", value: enabledSteps.isEmpty ? "—" : enabledSteps.joined(separator: ", "))
                    
                    PreviewRow(label: "Allow Reasons", value: viewModel.allowReasons ? "Yes" : "No")
                    PreviewRow(label: "Agreement Possibilities", value: viewModel.agreementPossibilities)
                    
                    if viewModel.allowReasons {
                        if viewModel.agreementPossibilities != "Reject" {
                            PreviewRow(label: "Accept Reasons", value: viewModel.acceptReasons.isEmpty ? "—" : viewModel.acceptReasons.joined(separator: ", "))
                            PreviewRow(label: "Accept Reason Required", value: viewModel.acceptReasonsRequired ? "Yes" : "No")
                        }
                        
                        if viewModel.agreementPossibilities != "Accept" {
                            PreviewRow(label: "Reject Reasons", value: viewModel.rejectReasons.isEmpty ? "—" : viewModel.rejectReasons.joined(separator: ", "))
                            PreviewRow(label: "Reject Reason Required", value: viewModel.rejectReasonsRequired ? "Yes" : "No", showDivider: false)
                        } else {
                            PreviewRow(label: "Accept Reason Required", value: viewModel.acceptReasonsRequired ? "Yes" : "No", showDivider: false)
                        }
                    } else {
                        PreviewRow(label: "Agreement Possibilities", value: viewModel.agreementPossibilities, showDivider: false)
                    }
                }
                
                // MARK: - Advanced Settings Section
                SectionView(title: "Advanced Settings") {
                    PreviewRow(label: "Access Control", value: viewModel.accessControl)
                    PreviewRow(label: "Custody LTA", value: viewModel.custodyLTAEnabled ? "Enabled" : "Disabled")
                    PreviewRow(label: "Notarial Deposit", value: viewModel.notarialDepositEnabled ? "Enabled" : "Disabled")
                    
                    if viewModel.notarialDepositEnabled {
                        PreviewRow(label: "Push Notification URL", value: viewModel.notarialDepositURL.isEmpty ? "—" : viewModel.notarialDepositURL)
                    }
                    
                    PreviewRow(label: "Cost Centre", value: viewModel.costCentreEnabled ? "Enabled" : "Disabled", showDivider: false)
                }
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color(.systemBackground))
    }
    
    /// Formatta la data di tracking in forma leggibile.
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Section View
/// Contenitore visuale riusabile per sezioni dell'anteprima.
struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.88, green: 0.95, blue: 0.92))
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemGray6))
            .cornerRadius(0, corners: [.bottomLeft, .bottomRight])
        }
        .cornerRadius(12)
        .padding(.vertical, 8)
    }
}

// MARK: - Preview Row
/// Riga label/valore usata nel riepilogo.
struct PreviewRow: View {
    let label: String
    let value: String
    var showDivider: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(value)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.primary)
                .lineLimit(nil)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.lightGreen.opacity(0.04)))
        .overlay(
            showDivider ? AnyView(
                VStack {
                    Spacer()
                    Divider()
                        .padding(.horizontal, 16)
                }
            ) : AnyView(EmptyView()),
            alignment: .bottom
        )
    }
}

// MARK: - Corner Radius Extension
extension View {
    /// Applica corner radius solo ai corner specificati.
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

/// Shape helper per corner radius selettivo.
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#Preview {
    PreviewTabView(viewModel: ComposeMailViewModel())
}
