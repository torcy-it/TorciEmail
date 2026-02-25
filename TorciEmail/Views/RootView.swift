//
//  RootView.swift
//  TorciEmail
//
//  Punto di ingresso visuale dell'app.
//  Instrada tra login e area autenticata.
//

import SwiftUI

/// Instradamento UI principale basato sullo stato autenticazione.
struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    /// Mostra mailbox se autenticato, altrimenti login.
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MailboxView()
                    .overlay {
                        if authViewModel.showSessionExpired {
                            SessionExpired {
                                authViewModel.dismissSessionExpired()
                            }
                            .zIndex(999)
                        }
                    }
            } else {
                LoginPageView()
            }
        }
    }
}
