import SwiftUI

// MARK: - Tab Types
enum ComposeTab: CaseIterable {
    case content
    case certification
    case advanced
    case preview

    var icon: String {
        switch self {
        case .content:        return "envelope"
        case .certification:  return "checkmark.seal"
        case .advanced:       return "gearshape"
        case .preview:        return "eye"
        }
    }

    var title: String {
        switch self {
        case .content:        return "Content  "
        case .certification:  return "Certification"
        case .advanced:       return "Settings"
        case .preview:        return "Preview"
        }
    }
}

// MARK: - Compose Tab Bar
struct ComposeTabBar: View {
    @Binding var selectedTab: ComposeTab

    private let tealColor = Color.backGroundCard
    private let tealIcon  = Color.black.opacity(0.80)
    private let grayBg    = Color.gray.opacity(0.20)
    private let grayIcon  = Color.gray.opacity(0.60)

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ComposeTab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isSelected ? tealIcon : grayIcon)

                        if isSelected {
                            Text(tab.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(tealIcon)
                                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, isSelected ? 16 : 0)
                    .frame(maxWidth: isSelected ? .infinity : 52, minHeight: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .fill(isSelected ? tealColor : grayBg)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selected: ComposeTab = .content

    VStack {
        ComposeTabBar(selectedTab: $selected)
        Spacer()
        Text("Selected: \(selected.title)")
            .foregroundColor(.secondary)
        Spacer()
    }
    .background(Color(.systemBackground))
}
