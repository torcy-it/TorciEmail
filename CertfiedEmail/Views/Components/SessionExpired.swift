//
//  SessionExpiredView.swift
//  CertfiedEmail
//
//  Overlay di sessione scaduta.
//  Blocca la UI e richiede ritorno al login.
//


import SwiftUI

/// Vista modale full-screen mostrata quando il JWT non e piu valido.
struct SessionExpired: View {
    let onDismiss: () -> Void
    
    /// Mostra messaggio di sessione scaduta e azione di conferma.
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Session Expired")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Your session has expired.\nPlease log in again.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button(action: onDismiss) {
                    Text("Go to Login")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            )
            .padding(.horizontal, 40)
        }
        .transition(.opacity.combined(with: .scale))
    }
}
