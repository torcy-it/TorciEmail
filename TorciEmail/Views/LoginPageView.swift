//
//  LoginPageView.swift
//  TorciEmail
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
                    .accessibilityLabel(authViewModel.isPasswordVisible ? "Nascondi password" : "Mostra password")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .disabled(authViewModel.isLoading)
            }
            
            if authViewModel.remainingLockoutSeconds > 0 {
                Text("Troppi tentativi. Riprova tra \(authViewModel.remainingLockoutSeconds)s.")
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
            .disabled(authViewModel.userEmail.isEmpty || authViewModel.password.isEmpty || authViewModel.isLoading || authViewModel.remainingLockoutSeconds > 0)
            
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
        .alert("Abilitare Face ID / Touch ID?", isPresented: $authViewModel.showEnableBiometricsPrompt) {
            Button("Non ora", role: .cancel) {
                authViewModel.skipBiometricEnable()
            }
            Button("Abilita") {
                Task {
                    await authViewModel.enableBiometrics()
                }
            }
        } message: {
            Text("Potrai accedere più velocemente dopo il primo login.")
        }
    }
}

#Preview {
    LoginPageView()
        .environmentObject(AuthViewModel.shared)
}
