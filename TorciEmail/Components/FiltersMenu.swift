//
//  CategoriesMenu.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import SwiftUI
struct FiltersMenu: View {
    @Binding var selectedCategory: String
    @Binding var showMenu: Bool
    @State private var pressedItem: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {

            menuItem("paperplane", "Sent")
            menuItem("flag", "Flagged")
            menuItem("star", "Important")
            menuItem("pencil.and.outline", "Drafts")
            menuItem("calendar", "Scheduled")
            menuItem("exclamationmark.triangle", "Spam")
            menuItem("tray.full", "All Inbox")

        }
        .padding(.vertical, 16.58)
        .padding(.horizontal, 16.58)
        .frame(width:168.6, height:370.08)
        .background(
            RoundedRectangle(cornerRadius: 20.73, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius:20.73)
                        .fill(Color("ButtonColor"))
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
                        .foregroundColor(.black)
                }
            }
            .foregroundColor(.black)
             .background(
                 RoundedRectangle(cornerRadius: 12)
                     .fill(pressedItem == label ? Color("ButtonColor").opacity(0.3) : Color.clear)  // ← Blu più chiaro
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
            HStack(spacing: 6.91) {
                Image(systemName: "tray.full")
                    .font(Font.system(size: 16.58, weight: .medium))
                Text("All Inbox")
                Image(systemName: "chevron.down")
                    .font(Font.system(size: 16.58, weight: .semibold))
                    .rotationEffect(.degrees(showMenu ? 180 : 0))
            }
            .font(.system(size: 16.58, weight: .semibold))
            .foregroundColor(.black)
            .padding(.horizontal, 11.06)
            .padding(.vertical, 16.58)
            .frame(width: 174.13, height: 52.51)

            .background(
                RoundedRectangle(cornerRadius: 20.73, style: .continuous)
                    .fill(Color("ButtonColor"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20.73, style: .continuous)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

