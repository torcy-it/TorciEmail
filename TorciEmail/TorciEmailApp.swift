//
//  TorciEmailApp.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import SwiftUI

@main
struct TorciEmailApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MailboxView()
            } else {
                LoginPageView()
            }
        }
    }
}
