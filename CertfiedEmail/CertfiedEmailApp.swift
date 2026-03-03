//
//  CertfiedEmailApp.swift
//  CertfiedEmail
//
//  Entry point applicazione iOS.
//  Inietta dipendenze globali nel root tree SwiftUI.
//

import SwiftUI

@main
/// Tipo principale dell'app SwiftUI.
struct CertfiedEmailApp: App {
    @StateObject private var authViewModel = AuthViewModel.shared
    
    /// Avvia la scena principale con `RootView`.
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .preferredColorScheme(.light)
        }
    }
}
