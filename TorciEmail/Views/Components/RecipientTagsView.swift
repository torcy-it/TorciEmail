import SwiftUI

struct RecipientTagsView: View {
    let label: String
    @Binding var recipients: [String]
    @State private var currentInput: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Label
            Text(label)
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)

            // Pills + TextField
            VStack(alignment: .leading, spacing: 8) {
                ForEach(createRows(), id: \.id) { row in
                    HStack(spacing: 8) {
                        ForEach(row.elements, id: \.id) { element in
                            if element.isPill {
                                EmailPill(email: element.content) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        recipients.removeAll { $0 == element.content }
                                    }
                                }
                            } else {
                                TextField("", text: $currentInput)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()
                                    .focused($isTextFieldFocused)
                                    .onSubmit { addEmailFromInput() }
                                    .submitLabel(.done)
                                    .frame(minWidth: 100)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }
    private func createRows() -> [RowData] {
        var rows: [RowData] = []
        var currentRow: [ElementData] = []
        var currentRowWidth: CGFloat = 0
        let maxWidth: CGFloat = 300 // Larghezza disponibile per il contenuto
        
        // Aggiungi tutte le pills
        for (index, email) in recipients.enumerated() {
            let pillWidth = estimatePillWidth(email)
            
            // Se non ci sta nella riga corrente, crea nuova riga
            if currentRowWidth + pillWidth > maxWidth && !currentRow.isEmpty {
                rows.append(RowData(id: "row-\(rows.count)", elements: currentRow))
                currentRow = []
                currentRowWidth = 0
            }
            
            currentRow.append(ElementData(
                id: "pill-\(index)-\(email)",
                content: email,
                isPill: true
            ))
            currentRowWidth += pillWidth + 8
        }
        
        // Aggiungi il TextField
        let textFieldWidth: CGFloat = 120
        if currentRowWidth + textFieldWidth > maxWidth && !currentRow.isEmpty {
            rows.append(RowData(id: "row-\(rows.count)", elements: currentRow))
            currentRow = []
        }
        
        currentRow.append(ElementData(
            id: "textfield",
            content: "",
            isPill: false
        ))
        
        rows.append(RowData(id: "row-\(rows.count)", elements: currentRow))
        
        return rows
    }
    
    private func estimatePillWidth(_ email: String) -> CGFloat {
        let textWidth = CGFloat(email.count) * 8.5
        return textWidth + 40
    }
    
    private func addEmailFromInput() {
        let trimmedEmail = currentInput.trimmingCharacters(in: .whitespaces)

        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            recipients.append(trimmedEmail)
        }
        currentInput = ""
        
        // Mantieni il focus sul TextField
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isTextFieldFocused = true
        }
    }
}

// MARK: - Supporting Types
struct RowData: Identifiable {
    let id: String
    let elements: [ElementData]
}

struct ElementData: Identifiable {
    let id: String
    let content: String
    let isPill: Bool
}

// MARK: - Email Pill Component
struct EmailPill: View {
    let email: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(email)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.black.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.backGroundCard)
        )
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var toRecipients: [String] = ["adolfo@icloud.com", "test@email.com"]
    @Previewable @State var ccRecipients: [String] = []
    
    VStack {
        RecipientTagsView(
            label: "To:",
            recipients: $toRecipients
        )
        
        Divider()
        
        RecipientTagsView(
            label: "Cc:",
            recipients: $ccRecipients
        )
    }
    .padding()
}
