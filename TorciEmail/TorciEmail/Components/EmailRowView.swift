//
//  EmailRowView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//
import SwiftUI

struct EmailRowView: View {
    let email: EmailItem
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "apple.logo")
                            .foregroundColor(.white)
                            .font(.system(size: 26))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(email.senderName)
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))

                        Spacer()

                        Text(email.date)
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 15))

                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.4))
                    }

                    Text(email.emailObject)
                        .foregroundColor(.white)
                        .font(.system(size: 17))

                    Text(email.emailDescription)
                        .foregroundColor(.white.opacity(0.55))
                        .font(.system(size: 14))
                }
            }
            .padding(.vertical, 12)

            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 1)
                .padding(.leading, 70)
        }
    }
}
