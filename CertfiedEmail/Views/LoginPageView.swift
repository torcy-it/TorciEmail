//
//  LoginPageView.swift
//  CertfiedEmail
//
//  Schermata di autenticazione utente.
//  Raccoglie credenziali e avvia il flusso login.
//

import SwiftUI

/// View di login con binding diretto ad `AuthViewModel`.
struct LoginPageView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    /// Costruisce il form di autenticazione e gestione errori.
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
                TextField("Your Email", text: $authViewModel.userEmail)
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .disabled(authViewModel.isLoading)
                
                HStack(spacing: 12) {
                    Group {
                        if authViewModel.isPasswordVisible {
                            TextField("Your Password", text: $authViewModel.password)
                        } else {
                            SecureField("Your Password", text: $authViewModel.password)
                        }
                    }
                    .textContentType(.password)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    
                    Button {
                        authViewModel.isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: authViewModel.isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundStyle(.secondary)
                    }
                    .disabled(authViewModel.isLoading)
                    .accessibilityLabel(authViewModel.isPasswordVisible ? "Hide password" : "Show password")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .disabled(authViewModel.isLoading)
            }
            
            if authViewModel.remainingLockoutSeconds > 0 {
                Text("Too many attempts. Try again in \(authViewModel.remainingLockoutSeconds)s.")
                    .foregroundColor(.orange)
                    .font(.system(size: 13, weight: .medium))
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
                            .progressViewStyle(
                                CircularProgressViewStyle(
                                    tint: isLoginDisabled ? .white.opacity(0.8) : .black
                                )
                            )
                    } else {
                        Text("Login")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    isLoginDisabled
                        ? Color(.systemGray4)
                        : Color("PrimaryColor")
                )
                .foregroundColor(isLoginDisabled ? .white.opacity(0.9) : .black)
                .cornerRadius(14)
                .font(Font.system(size: 18, weight: .semibold))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isLoginDisabled ? Color(.systemGray3) : Color.clear,
                            lineWidth: 1
                        )
                )
            }
            .disabled(isLoginDisabled)
            .opacity(isLoginDisabled ? 0.9 : 1)
            
            if isMissingCredentials && !authViewModel.isLoading && authViewModel.remainingLockoutSeconds == 0 {
                Text("Enter email and password to continue")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            if authViewModel.hasStoredSession && authViewModel.biometricsEnabled && authViewModel.canUseBiometrics {
                Button {
                    Task {
                        await authViewModel.unlockWithBiometrics()
                    }
                } label: {
                    Text(authViewModel.biometricButtonTitle)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(14)
                        .font(.system(size: 16, weight: .semibold))
                }
                .disabled(authViewModel.isLoading)
            }
            
            Spacer()
        }
        .padding()
        .alert("Enable Face ID / Touch ID?", isPresented: $authViewModel.showEnableBiometricsPrompt) {
            Button("Not now", role: .cancel) {
                authViewModel.skipBiometricEnable()
            }
            Button("Enable") {
                Task {
                    await authViewModel.enableBiometrics()
                }
            }
        } message: {
            Text("You will be able to sign in faster after your first login.")
        }
    }
    
    private var isMissingCredentials: Bool {
        authViewModel.userEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        authViewModel.password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isLoginDisabled: Bool {
        isMissingCredentials || authViewModel.isLoading || authViewModel.remainingLockoutSeconds > 0
    }
}

#Preview {
    LoginPageView()
        .environmentObject(AuthViewModel.shared)
}
