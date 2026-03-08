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
    #if DEBUG
    @State private var showServerConfigSheet = false
    @State private var showServerConfigError = false
    @State private var serverConfigErrorMessage = ""
    #endif
    
    /// Costruisce il form di autenticazione e gestione errori.
    var body: some View {
        ZStack(alignment: .topTrailing) {
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
                
                Spacer()
            }
            #if DEBUG
            HStack(spacing: 8) {
                Button {
                    showServerConfigSheet = true
                } label: {
                    Label("Server", systemImage: "network")
                        .labelStyle(.iconOnly)
                        .frame(width: 34, height: 34)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                
                Button {
                    authViewModel.errorMessage = nil
                    authViewModel.isLoading = false
                    if authViewModel.userEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        authViewModel.userEmail = "offline@local"
                    }
                    authViewModel.isAuthenticated = true
                } label: {
                    Label("Offline", systemImage: "wifi.slash")
                        .labelStyle(.iconOnly)
                        .frame(width: 34, height: 34)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 4)
            .padding(.trailing, 4)
            #endif
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
        #if DEBUG
        .sheet(isPresented: $showServerConfigSheet) {
            DebugServerConfigSheet(
                currentEndpoint: AppConfig.apiBaseURL,
                defaultEndpoint: AppConfig.defaultConfiguredBaseURLForDebugDisplay(),
                onApply: { value in
                    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard let url = URL(string: trimmed),
                          let scheme = url.scheme?.lowercased(),
                          (scheme == "http" || scheme == "https"),
                          url.host != nil else {
                        serverConfigErrorMessage = "Enter a valid server URL (http/https)."
                        showServerConfigError = true
                        return
                    }
                    
                    AppConfig.setDebugBaseURLOverride(trimmed)
                },
                onReset: {
                    AppConfig.clearDebugBaseURLOverride()
                }
            )
        }
        .alert("Invalid Server URL", isPresented: $showServerConfigError) {
            Button("OK", role: .cancel) {
                showServerConfigError = false
            }
        } message: {
            Text(serverConfigErrorMessage)
        }
        #endif
    }
    
    private var isMissingCredentials: Bool {
        authViewModel.userEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        authViewModel.password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isLoginDisabled: Bool {
        isMissingCredentials || authViewModel.isLoading || authViewModel.remainingLockoutSeconds > 0
    }
}

#if DEBUG
private struct DebugServerConfigSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var endpoint: String
    let currentEndpoint: String
    let defaultEndpoint: String
    let onApply: (String) -> Void
    let onReset: () -> Void
    
    init(
        currentEndpoint: String,
        defaultEndpoint: String,
        onApply: @escaping (String) -> Void,
        onReset: @escaping () -> Void
    ) {
        self.currentEndpoint = currentEndpoint
        self.defaultEndpoint = defaultEndpoint
        self.onApply = onApply
        self.onReset = onReset
        _endpoint = State(initialValue: currentEndpoint)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Current endpoint") {
                    Text(currentEndpoint)
                        .font(.system(size: 13))
                        .textSelection(.enabled)
                }
                
                Section("Server URL") {
                    TextField("http://192.168.x.x:8080", text: $endpoint)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                }
                
                Section("Default fallback") {
                    Text(defaultEndpoint)
                        .font(.system(size: 13))
                        .textSelection(.enabled)
                }
                
                Section {
                    Button("Reset to default") {
                        onReset()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Debug Server")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        onApply(endpoint)
                        dismiss()
                    }
                }
            }
        }
    }
}
#endif

#Preview {
    LoginPageView()
        .environmentObject(AuthViewModel.shared)
}
