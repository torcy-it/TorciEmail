//
//  ProfileButton.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//
import SwiftUI

struct ProfileButton: View {
    var body: some View {

        NavigationLink(destination: ProfileView()) {
            VStack(spacing: 4) {
                Image("watermelon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(radius: 6)

                Text("Adolfo")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}
