//
//  FiltersMenu.swift
//  CertfiedEmail
//
//  Menu filtri mailbox e bottone di attivazione.
//
import SwiftUI

/// Tipo icona supportato dal menu filtri.
enum FilterIcon {
    case asset(String)
    case system(String)
}

/// Elemento dati singolo per il menu filtri.
struct MenuItem: Identifiable {
    let id = UUID()
    let icon: FilterIcon
    let label: String
}

/// Overlay menu con scelta filtro mailbox.
struct FiltersMenu: View {
    @Binding var selectedFilters: String
    @Binding var showMenu: Bool
    @State private var pressedItem: String? = nil
    @Namespace private var namespace

    private let menuItems: [MenuItem] = [
        .init(icon: .system("arrow.right.circle"), label: "Sent"),
        .init(icon: .system("checkmark.circle"), label: "Delivered"),
        .init(icon: .system("xmark.circle"), label: "Failed"),
        .init(icon: .system("bolt.ring.closed"), label: "Actives"),
        .init(icon: .system("pencil.circle"), label: "Drafts"),
        .init(icon: .system("checkmark.seal"), label: "Closed"),
        .init(icon: .system("tray.full"), label: "All Inbox")
    ]

    /// Costruisce il menu animato e il contenuto selezionabile.
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(visibleItems) { item in
                menuItem(item)
                    .glassEffectID(item.label, in: namespace)
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 17)
        .frame(width: 180)
        .glassEffect(.regular.tint(Color("PrimaryColor").opacity(0.30)), in: .rect(cornerRadius: 21.0))
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
    }

    private var visibleItems: [MenuItem] {
        showMenu ? menuItems : Array(menuItems.prefix(3))
    }

    /// Singola riga selezionabile del menu.
    private func menuItem(_ item: MenuItem) -> some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()

            pressedItem = item.label

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    selectedFilters = item.label
                    showMenu = false
                    pressedItem = nil
                }
            }
        } label: {
            HStack(spacing: 16) {
                iconView(item.icon)

                Text(item.label)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)

                if selectedFilters == item.label {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .foregroundColor(.black)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .frame(width: 160, alignment: .leading)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(pressedItem == item.label ? 0.08 : 0.0))
            )
            .scaleEffect(pressedItem == item.label ? 0.97 : 1.0)
            .opacity(pressedItem == item.label ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.12), value: pressedItem == item.label)
        }
        .buttonStyle(.plain)
    }

}


/// Bottone che apre/chiude il menu filtri.
struct FiltersButton: View {
    @Binding var showMenu: Bool
    @Binding var selectedFilter: String
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                showMenu.toggle()
            }
        } label: {
            HStack(spacing: 16) {
                iconView(iconForFilter(selectedFilter))
                
                Text(selectedFilter)
                    .lineLimit(1)
                    .font(.system(size: 18, weight: .semibold))
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .semibold))
                    .rotationEffect(.degrees(showMenu ? 180 : 0))
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)
            .padding(.horizontal, 11)
            .padding(.vertical, 17)
            .frame(width: 180, height: 50)
            .glassEffect(.regular.tint(Color("PrimaryColor").opacity(0.30)), in: .rect(cornerRadius: 21.0))
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    /// Associa filtro corrente all'icona rappresentativa.
    private func iconForFilter(_ filter: String) -> FilterIcon {
        switch filter {
        case "Sent":
            return .system("arrow.right.circle")
        case "Delivered":
            return .system("checkmark.circle")
        case "Failed":
            return .system("xmark.circle")
        case "Drafts":
            return .system("pencil.circle")
        case "Actives":
            return .system("bolt.ring.closed")
        case "Closed":
            return .system("checkmark.seal")
        default:
            return .system("tray.full")
        }
    }
    
}

@ViewBuilder
/// Renderizza icona sistema o asset in modo uniforme.
private func iconView(
    _ icon: FilterIcon
) -> some View {
    switch icon {
    case .system(let name):
        Image(systemName: name)
            .font(.system(size: 23, weight: .medium))
            .frame(width: 22, alignment: .leading)
    
    case .asset(let name):
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 28)
            .frame(width: 22, alignment: .leading)
    }
}


#Preview {
    MailboxView()
}

