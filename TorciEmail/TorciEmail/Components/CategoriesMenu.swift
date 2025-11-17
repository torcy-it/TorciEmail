//
//  CategoriesMenu.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import SwiftUI
struct CategoriesMenu: View {
    @Binding var selectedCategory: String
    @Binding var showMenu: Bool
    @State private var pressedItem: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {

            menuItem("paperplane", "Sent")
            menuItem("flag", "Flagged")
            menuItem("star", "Important")
            menuItem("pencil.and.outline", "Drafts")
            menuItem("cart", "Purchases")
            menuItem("clock", "Snoozed")
            menuItem("calendar", "Scheduled")
            menuItem("exclamationmark.triangle", "Spam")
            menuItem("tray.and.arrow.up", "Outbox")
            menuItem("trash", "Bin")
            menuItem("tray.full", "All Inbox")

        }
        .padding(.vertical, 24)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 36)
                        .fill(Color(red: 17/255, green: 24/255, blue: 39/255))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 36)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.35), radius: 25, y: 12)
    }

    private func menuItem(_ icon: String, _ label: String) -> some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            pressedItem = label
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedCategory = label
                    showMenu = false
                    pressedItem = nil
                }
            }
        }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .regular))
                Text(label)
                    .font(.system(size: 17, weight: .medium))
                Spacer()
               
                if selectedCategory == label {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .foregroundColor(.white)
             .padding(.horizontal, 12)
             .padding(.vertical, 10)
             .background(
                 RoundedRectangle(cornerRadius: 12)
                     .fill(pressedItem == label ? Color(red: 59/255, green: 130/255, blue: 246/255).opacity(0.3) : Color.clear)  // ← Blu più chiaro
             )
             .scaleEffect(pressedItem == label ? 0.96 : 1)
             .animation(.spring(response: 0.2, dampingFraction: 0.7), value: pressedItem)
         }
         .buttonStyle(.plain)
    }
}

struct CategoriesButton: View {
    @Binding var showMenu: Bool

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                showMenu.toggle()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "tray.full")
                Text("Categories")
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(showMenu ? 180 : 0))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .fill(
                        Color(red: 17/255, green: 24/255, blue: 39/255)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
            )
        }
    }
}
