//
//  LoginPageView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 20/01/26.
//

import SwiftUI

struct LoginPageView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
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
                TextField("Your Email", text: $authViewModel.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .disabled(authViewModel.isLoading)
                
                SecureField("Your Password", text: $authViewModel.password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .disabled(authViewModel.isLoading)
            }
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
            }
            
            Button {
                Task {
                    await authViewModel.login()
                }
            } label: {
                HStack {
                    if authViewModel.isLoading {
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
            .disabled(authViewModel.username.isEmpty || authViewModel.password.isEmpty || authViewModel.isLoading)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginPageView()
        .environmentObject(AuthViewModel.shared)
}
