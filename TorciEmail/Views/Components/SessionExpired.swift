//
//  SessionExpiredView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//


import SwiftUI

struct SessionExpired: View {
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Icona
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                // Titolo
                Text("Sessione Scaduta")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                // Messaggio
                Text("La tua sessione è scaduta.\nEffettua nuovamente il login.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Pulsante
                Button(action: onDismiss) {
                    Text("Vai al Login")
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
