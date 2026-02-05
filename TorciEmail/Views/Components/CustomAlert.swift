//
//  CustomAlertView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//


import SwiftUI

struct CustomAlert: View {
    let title: String
    let message: String
    let primaryButton: AlertButton
    let secondaryButton: AlertButton?
    
    init(
        title: String,
        message: String,
        primaryButton: AlertButton,
        secondaryButton: AlertButton? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
    
    var body: some View {
        ZStack {
            // Sfondo scuro con blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Chiudi toccando fuori (opzionale)
                }
            
            // Card del popup
            VStack(spacing: 20) {
                // Titolo
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                // Messaggio
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Pulsanti
                VStack(spacing: 12) {
                    // Pulsante primario
                    Button(action: primaryButton.action) {
                        Text(primaryButton.title)
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(buttonColor(for: primaryButton.style))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    // Pulsante secondario (opzionale)
                    if let secondary = secondaryButton {
                        Button(action: secondary.action) {
                            Text(secondary.title)
                                .font(.system(size: 17, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            )
            .padding(.horizontal, 40)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: true)
    }
    
    private func buttonColor(for style: AlertButton.Style) -> Color {
        switch style {
        case .default:
            return Color.blue
        case .cancel:
            return Color.gray
        case .destructive:
            return Color.red
        }
    }
}
