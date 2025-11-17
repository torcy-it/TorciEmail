//
//  BottomBarView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import SwiftUI
struct BottomBar: View {
    @Binding var searchText: String
    var onFilterTap: () -> Void   
    
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 20) {

            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                
                TextField(
                    "",
                    text: $searchText,
                    prompt: Text("Search")
                        .foregroundColor(.white.opacity(0.6))
                )
                .foregroundColor(.white)
                .focused($focused)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.30), lineWidth: 1)
                    )
            )

            circleButton("line.3.horizontal.decrease") {
                onFilterTap()
            }
            
            circleButton("square.and.pencil") { }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    func circleButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.35), lineWidth: 1.1)
                    )

                Image(systemName: icon)
                    .foregroundColor(.white)
            }
            .frame(width: 50, height: 50)
        }
        .buttonStyle(.plain)
    }
}
