//
//  SelectRow.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 21/01/26.
//


import SwiftUI


struct EmailView: View {


    // Selection
    @State private var selectedCertifiedTitle: String = "EviMail"
    @State private var selectedTypeTitle: String = "My EviMail"
    @Binding var showModal: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 28) {

                SectionHeader("Certified Communication")
                    .padding(.top, 48)

                SelectCard(
                    rows: certified,
                    selectedTitle: $selectedCertifiedTitle
                )

                SectionHeader("Type of")

                SelectCard(
                    rows: typeOf,
                    selectedTitle: $selectedTypeTitle
                )

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 18)
            .toolbar {
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        
                        showModal.toggle()
                    } label : {
                        Text(Image(systemName: "checkmark"))
                            .foregroundColor(.black)
                            .font(.system(size: 16.58, weight: .medium))
                            .frame(width: 48, height: 48)
                            .glassEffect(.regular.tint(Color("ButtonColor").opacity(0.80)))
                            .shadow(
                                color: .black.opacity(0.25),
                                radius: 2,
                                x: 0,
                                y: 4
                            )
                    }
                    .buttonStyle(.plain)
                   
                }.sharedBackgroundVisibility(.hidden)
            }
            .navigationTitle("Categories")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
    }
}


private struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(.primary)
            .padding(.leading, 4)
    }
}

private struct SelectCard: View {
    let rows: [SelectRow]
    @Binding var selectedTitle: String

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { idx, row in
                Button {
                    selectedTitle = row.title
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: row.icon)
                            .font(.system(size: 22, weight: .regular))
                            .frame(width: 34, alignment: .center)
                            .foregroundStyle(.primary)

                        Text(row.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.primary)

                        Spacer()

                        if selectedTitle == row.title {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color(red: 153/255, green: 196/255, blue: 193/255))
                        }
                    }
                    .padding(.vertical, 18)
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Divider (not after last)
                if idx < rows.count - 1 {
                    Divider()
                        .padding(.leading, 16 + 34 + 14) // align divider after icon
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 8)
    }
}


#Preview {
    EmailView( showModal: .constant(true))
    
}
