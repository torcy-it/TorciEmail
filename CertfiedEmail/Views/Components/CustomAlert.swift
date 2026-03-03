//
//  CustomAlertView.swift
//  CertfiedEmail
//
//  Alert custom full-screen con uno o due pulsanti.
//


import SwiftUI

/// Popup modale custom per conferme bloccanti lato UI.
struct CustomAlert: View {
    let title: String
    let message: String
    let primaryButton: AlertButton
    let secondaryButton: AlertButton?
    
    /// Inizializza l'alert con titolo, messaggio e azioni.
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
    
    /// Disegna overlay, contenuto e bottoni d'azione.
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { }
            
            VStack(spacing: 20) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(spacing: 12) {
                    Button(action: primaryButton.action) {
                        Text(primaryButton.title)
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(buttonColor(for: primaryButton.style))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
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
    
    /// Ritorna il colore coerente con lo stile del pulsante.
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
