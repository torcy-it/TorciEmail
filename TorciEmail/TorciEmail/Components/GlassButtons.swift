//
//  GlassButtons.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import SwiftUI

extension View {
    
    func glassCapsuleButton(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.white)
            .font(.system(size: 17, weight: .semibold))
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
            )
    }
    
}

func glassCategoriesButton(showMenu: Binding<Bool>) -> some View {
    Button {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            showMenu.wrappedValue.toggle()
        }
    } label: {
        HStack(spacing: 8) {
            Image(systemName: "tray.full")
                .font(.system(size: 17, weight: .medium))
            Text("Categories")
                .font(.system(size: 17, weight: .semibold))
            Image(systemName: "chevron.down")
                .font(.system(size: 13, weight: .bold))
                .rotationEffect(.degrees(showMenu.wrappedValue ? 180 : 0))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.345, green: 0.490, blue: 0.863).opacity(0.20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
        )
    }
}



var glassAvatar: some View {
    Image("avatar")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 42, height: 42)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(radius: 6)
}
