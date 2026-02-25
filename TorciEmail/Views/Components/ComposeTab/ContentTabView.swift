//
//  ContentTabView.swift
//  TorciEmail
//
//  Tab di composizione contenuto: destinatari, oggetto, corpo, allegato e opzioni base.
//


import SwiftUI

/// Vista SwiftUI del tab "Content" nella compose.
struct ContentTabView: View {
    @ObservedObject var viewModel: ComposeMailViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - To Field
            RecipientTagsView(
                label: "To:",
                recipients: $viewModel.toRecipients,
                onAddRecipient: { email, name in
                    viewModel.recipientNames[email] = name
                }
            )
            .padding(.horizontal)
            .padding(.vertical, 12)

            Divider()

            // MARK: - CC/BCC and From (Expandable with DisclosureGroup)
            DisclosureGroup(
                isExpanded: $viewModel.showCc,
                content: {
                    VStack(spacing: 16) {
                
                        RecipientTagsView(
                            label: "Cc:",
                            recipients: $viewModel.ccRecipients,
                            onAddRecipient: { email, name in
                                viewModel.ccRecipientsNames[email] = name
                            }
                        )
                        .padding(.horizontal)
                        
                        Divider()
                        
                        Menu {
                            ForEach(viewModel.availableFromEmails, id: \.self) { email in
                                Button {
                                    viewModel.fromEmail = email
                                } label: {
                                    if viewModel.fromEmail == email {
                                        Label(email, systemImage: "checkmark")
                                    } else {
                                        Text(email)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("From:")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(viewModel.fromEmail)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(.tail))
                            }.padding(.horizontal)
                        }
                        
                        Divider()
                        
                        HStack {
                            
                            Text("Issuer Identification:")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                            Spacer()
                            TextField("", text: $viewModel.issuerName)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .frame(width: 140)
                            
                        }
                        .padding(.horizontal)
                     
                    }
                    .padding(.top, 8)
                    
                },
                label: {
                    HStack {
                        Text("Cc, From: ")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(viewModel.fromEmail)
                            .font(.system(size: 16))
                            .foregroundColor(Color(.tail))
                    }
                    .padding(.horizontal)
                }
            )
            .padding(.vertical, 16)
            .disclosureGroupStyle(CustomDisclosureStyle())

            Divider()

            // MARK: - Subject
            TextField("Subject:", text: $viewModel.subject)
                .font(.system(size: 16))
                .padding(.horizontal)
                .padding(.vertical, 16)

            Divider()

            // MARK: - Body
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.body)
                    .font(.system(size: 16))
                    .frame(minHeight: 150)
                    .scrollContentBackground(.hidden)

                if viewModel.body.isEmpty {
                    Text("Insert body email")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)

            // MARK: - Anteprima Allegato
            if let attachmentName = viewModel.selectedAttachmentName {
                HStack(spacing: 10) {
                    Image(systemName: "paperclip")
                        .foregroundColor(.secondary)
                    Text(attachmentName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Spacer()
                    Button {
                        viewModel.clearAttachment()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }

            Spacer(minLength: 20)

            // MARK: - Settings Section (with background)
            VStack(spacing: 0) {
                HStack {
                    Text("Remove sender header")
                        .font(.system(size: 17, weight: .medium))
                    Spacer()
                    Toggle("", isOn: $viewModel.removeSenderHeader)
                        .labelsHidden()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                HStack {
                    Text("Edit \"Reply-To\" header")
                        .font(.system(size: 17, weight: .medium))
                    Spacer()
                    Toggle("", isOn: $viewModel.showReplyTo.animation())
                        .labelsHidden()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                if viewModel.showReplyTo {
                    TextField("Reply To example@supp.com", text: $viewModel.replyToAddress)
                        .font(.system(size: 15))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground).opacity(0.6))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
            }
            .background(Color(red: 0.88, green: 0.95, blue: 0.92))
            .cornerRadius(16)
            .padding(.horizontal)
            .padding(.bottom, 20)

            // MARK: - Notification Language
            Menu {
                ForEach(viewModel.availableLanguages, id: \.self) { lang in
                    Button {
                        viewModel.language = lang
                    } label: {
                        if viewModel.language == lang {
                            Label(lang.uppercased(), systemImage: "checkmark")
                        } else {
                            Text(lang.uppercased())
                        }
                    }
                }
            } label: {
                HStack {
                    Text("Notification Language:")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(viewModel.language.uppercased())
                        .font(.system(size: 17))
                        .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(red: 0.88, green: 0.95, blue: 0.92))
            .cornerRadius(16)
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Custom Disclosure Style
struct CustomDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 0) {
            if !configuration.isExpanded {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        configuration.isExpanded.toggle()
                    }
                } label: {
                    configuration.label
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentTabView(viewModel: ComposeMailViewModel())
}
