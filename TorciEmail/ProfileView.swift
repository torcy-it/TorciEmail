//
//  ProfileView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//


import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 17/255, green: 24/255, blue: 39/255)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Avatar grande
                Image("avatar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(radius: 10)
                
                Text("Profile")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Il tuo profilo qui")
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
            }
            .padding(.top, 60)
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
                        Text("Back")
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}
