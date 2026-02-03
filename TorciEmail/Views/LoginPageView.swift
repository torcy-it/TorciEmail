//
//  LoginPageView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 20/01/26.
//

import SwiftUI

struct LoginPageView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 70) {
            
            VStack {
                Image("loginIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 193)
                
                Text("Log in to your account")
                    .font(.system(size: 24, weight: .semibold))
            }
            
            VStack(spacing: 39) {
                TextField("Your Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .disabled(viewModel.isLoading)

                SecureField("Your Password", text: $viewModel.password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .disabled(viewModel.isLoading)
            }
            
            // Messaggio di errore
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await viewModel.login()
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    } else {
                        Text("Login")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("PrimaryColor"))
                .foregroundColor(.black)
                .cornerRadius(14)
                .font(Font.system(size: 18, weight: .semibold))
            }
            .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)

            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $viewModel.isAuthenticated) {
            MailboxView()
        }
    }
}

#Preview { LoginPageView() }
