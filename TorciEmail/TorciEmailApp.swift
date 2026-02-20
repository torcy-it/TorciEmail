//
//  TorciEmailApp.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import SwiftUI
/*
@main
struct TorciEmailApp: App {
    @StateObject private var authViewModel = AuthViewModel.sh  ared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
*/

@main
struct TorciEmailApp: App {
    @State private var showCompose = false
    
    var body: some Scene {
        WindowGroup {
            EviMailComposeView()
        }
    }
}
