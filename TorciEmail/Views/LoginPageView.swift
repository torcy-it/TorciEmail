//
//  LoginPageView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 20/01/26.
//

import SwiftUI

struct LoginPageView: View {

    @State private var email = ""
    @State private var password = ""
    @State private var showHome = false

    var body: some View {
        // Rimuovi NavigationStack da qui - dovrebbe essere solo in ContentView
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

                TextField("Your Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)

                SecureField("Your Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
            }

            Button {
                showHome = true
            } label: {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("PrimaryColor"))
                    .foregroundColor(.black)
                    .cornerRadius(14)
                    .font(Font.system(size: 18, weight: .semibold))
            }
            .disabled(email.isEmpty || password.isEmpty)

            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $showHome) {
            MailboxView()
        }
    }
}

#Preview { LoginPageView() }
