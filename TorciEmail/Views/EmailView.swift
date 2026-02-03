//
//  SelectRow.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 21/01/26.
//

import SwiftUI

struct EmailView: View {

    @Environment(\.dismiss) var dismiss
    let email: EmailItem
    @State private var showDetailsModal = false
    @State private var showEmailInfoModal = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                header

                Divider().opacity(0.18)
                
                subject
                
                bodyCard
                
                if email.attachments.isEmpty { EmptyView() } else {
                    attachmentsCard
                }

                Spacer(minLength: 28)
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Email Details", systemImage: "info.circle") {
                    showDetailsModal.toggle()
                }
            }

            ToolbarItem(placement: .bottomBar) {
                Button("Certificates Details", systemImage: "checkmark.seal.text.page") {
                    showEmailInfoModal.toggle()
                }
            }

            ToolbarSpacer(.flexible, placement: .bottomBar)

            ToolbarItem(placement: .bottomBar) {
                Button("Download Content Email", systemImage: "square.and.arrow.down") { }
            }
        }
        .modifier(ScrollEdgeTuning())
        .sheet(isPresented: $showDetailsModal) {
            DetailsEmailView(showDetailsModal: $showDetailsModal)
        }
        .sheet(isPresented: $showEmailInfoModal) {
            CertificateEmailView(showEmailInfoModal: $showEmailInfoModal)
        }
    }



    private var header: some View {
        HStack(alignment: .top, spacing: 14) {

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(email.senderName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Spacer()

                    Text(email.date)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    infoRow(label: "To", value: recipientLine(for: email))
                    infoRow(label: "Cc", value: "Carbon Copy")
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
        Text(email.emailObject)
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 2)
    }
    
    private var attachmentsCard: some View {
        Group {
            if email.attachments.isEmpty {
                EmptyView()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "paperclip")
                            .foregroundStyle(.secondary)

                        Text("Attachments")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)

                        Text("• \(email.attachments.count)")
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
                        ForEach(email.attachments) { att in
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

            Text(bodyText(for: email))
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

    private func initials(from name: String) -> String {
        let parts = name
            .split(separator: " ")
            .prefix(2)
            .map { String($0.prefix(1)).uppercased() }
        return parts.joined()
    }
}


private func recipientLine(for email: EmailItem) -> String {
    let cleaned = email.senderName
        .lowercased()
        .replacingOccurrences(of: " ", with: "")
    return "\(cleaned)@example.com"
}

private func bodyText(for email: EmailItem) -> String {
    email.emailDescription + "\n\n" + email.emailDescription
}



#Preview {
    EmailView(email: EmailItem(
        senderName: "Recipient Name",
        emailObject: "Object of the email",
        emailDescription: """
In Middle earth, the Rings of Power were forged.
Three were given to the Elves ancient, wise, and undying.
Seven to the Dwarf-lords, masters of stone and craft.
And nine to Mortal Men, doomed to fade.
""",
        date: "12/03/25",
        status: .new,
        events: [
            .init(event: .sent, state: .sent(.sent), timestampUTC: Date()),
            .init(event: .open, state: .open(.opened), timestampUTC: Date()),
            .init(event: .decision, state: .decision(.waiting), timestampUTC: Date())
        ],
        attachments: [
            .init(name: "Certificate.pdf", sizeLabel: "1.2 MB", kind: .pdf),
            .init(name: "Photo_0123.jpg", sizeLabel: "820 KB", kind: .image),
            .init(name: "Report.docx", sizeLabel: "340 KB", kind: .doc),
            .init(name: "Export.zip", sizeLabel: "5.1 MB", kind: .zip)
        ]
    ))
}

