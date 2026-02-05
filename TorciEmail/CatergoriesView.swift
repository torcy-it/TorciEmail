import SwiftUI

struct SelectRow: Identifiable, Hashable {
    let id = UUID()
    let icon: String          // SF Symbol name
    let title: String
}

enum CardStyle {
    case flat
}

struct CategoriesView: View {


    private let certified: [SelectRow] = [
        .init(icon: "envelope", title: "EviMail"),
        .init(icon: "doc.text", title: "EviNotice"),
        .init(icon: "message", title: "EviSms"),
        .init(icon: "tray.and.arrow.up", title: "EviPost"),
        .init(icon: "signature", title: "EviSign")
    ]

    private let typeOf: [SelectRow] = [
        .init(icon: "envelope", title: "My EviMail"),
        .init(icon: "tray.full", title: "My Evimail Batches")
    ]

    // Selection
    @State private var selectedCertifiedTitle: String = "EviMail"
    @State private var selectedTypeTitle: String = "My EviMail"
    @Binding var showModal: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 28) {
                
                Text("Certified Communication")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.leading, 4)
                    .padding(.top, 48)


                SelectCard(
                    rows: certified,
                    selectedTitle: $selectedCertifiedTitle
                )

                Text("Type of")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.leading, 4)

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
                            .glassEffect(.regular.tint(Color("PrimaryColor").opacity(0.80)))
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
                                .foregroundStyle(Color("StrongPrimaryColor"))
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
    CategoriesView( showModal: .constant(true))
    
}
