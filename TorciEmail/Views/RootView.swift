//
//  RootView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
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
