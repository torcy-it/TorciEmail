//
//  AdvancedTabView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 20/02/26.
//

import SwiftUI

// MARK: - Advanced Tab View
struct AdvancedTabView: View {
    @ObservedObject var viewModel: ComposeMailViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                
                Menu {
                    ForEach(viewModel.custodyAccessControl, id: \.self) { access in
                        Button {
                            viewModel.accessControl = access
                        } label: {
                            if viewModel.accessControl == access {
                                Label(access.lowercased(), systemImage: "checkmark")
                            } else {
                                Text(access.lowercased())
                            }
                        }
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Custody Access Control")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)

                        HStack {
                            Text(viewModel.accessControl)
                                .font(.system(size: 17))
                                .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))

                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 16)
                }
                .background(Color(red: 0.88, green: 0.95, blue: 0.92))
                .cornerRadius(16)
                .padding(.horizontal)

                
                HStack {
                    Text("Custody LTA")
                        .font(.system(size: 17, weight: .medium))
                    Spacer()
                    Toggle("", isOn: $viewModel.custodyLTAEnabled)
                        .labelsHidden()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                HStack {
                    Text("Notarial Deposit")
                        .font(.system(size: 17, weight: .medium))
                    Spacer()
                    Toggle("", isOn: $viewModel.notarialDepositEnabled)
                        .labelsHidden()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Push Notifications")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 20)
                    
                    TextField("www.examplesite.com", text: $viewModel.notarialDepositURL)
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
            .blur(radius: viewModel.showFutureImplementationAlert ? 3 : 0)
            .disabled(viewModel.showFutureImplementationAlert)

            // MARK: - Popup (NON SFOCATO)
            if viewModel.showFutureImplementationAlert {
                VStack(spacing: 24) {
                    // Icon
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))

                    // Title
                    Text("Future Implementation")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)

                    // Message
                    Text("Advanced settings are set to default")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AdvancedTabView(
        viewModel: ComposeMailViewModel()
    )
}
