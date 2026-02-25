//
//  TorciEmailApp.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import SwiftUI

@main
struct TorciEmailApp: App {
    @StateObject private var authViewModel = AuthViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
