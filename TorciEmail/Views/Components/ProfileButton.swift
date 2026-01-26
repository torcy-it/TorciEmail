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
                    .frame(width: 50, height: 48)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(
                        color: .black.opacity(0.25),
                        radius: 2,
                        x: 0,
                        y: 4
                    )
                    

                Text("Adolfo")
                    .font(.system(size: 12))
                    .foregroundColor(.black.opacity(0.7))
            }
        }
    }
}
