//
//  ProfileView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVm: AuthViewModel
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        ZStack {
//            Color(red: 17/255, green: 24/255, blue: 39/255)
//                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Avatar grande
                Image("watermelon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(radius: 10)
                
                Text(String(authVm.userEmail.prefix { $0 != "@" }))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Pulsante Logout
                Button {
                    showLogoutConfirmation = true
                } label: {
                    HStack {
                        if authVm.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .font(.system(size: 18, weight: .semibold))
                }
                .disabled(authVm.isLoading)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .padding(.top, 60)
        
            if showLogoutConfirmation {
                CustomAlert(
                    title: "Logout",
                    message: "Sei sicuro di voler uscire?",
                    primaryButton: AlertButton(
                        title: "Logout",
                        style: .destructive,
                        action: {
                            showLogoutConfirmation = false
                            Task {
                                await authVm.logout()
                            }
                        }
                    ),
                    secondaryButton: AlertButton(
                        title: "Annulla",
                        style: .cancel,
                        action: {
                            showLogoutConfirmation = false
                        }
                    )
                )
                .zIndex(999)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.black)
                }
            }
        }

    }
}
