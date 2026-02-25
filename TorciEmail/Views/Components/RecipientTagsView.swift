import SwiftUI

struct RecipientTagsView: View {
    let label: String
    @Binding var recipients: [String]
    let onAddRecipient: (String, String) -> Void  // email, name
    @State private var currentInput: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    // Sheet state
    @State private var showNameSheet: Bool = false
    @State private var showAddSheet: Bool = false
    @State private var pendingEmail: String = ""
    @State private var recipientName: String = ""
    @State private var addSheetEmail: String = ""
    @State private var addSheetName: String = ""
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)

            VStack(alignment: .leading, spacing: 20) {
                ForEach(createRows(), id: \.id) { row in
                    HStack(spacing: 8) {
                        ForEach(row.elements, id: \.id) { element in
                            if element.isPill {
                                EmailPill(emailData: element.content) {
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
                                    .onSubmit { openNameSheet() }
                                    .submitLabel(.done)
                                    .frame(minWidth: 100)
                            }
                            
                            
                        }
                        .frame(height: 20)
                        
                    }
                }
            }
            
            Button {
                showAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
                    .frame(width: 8, height: 18)
                    .contentShape(Circle())
            }
            .frame(width: 40, height: 20)
            .buttonStyle(.glass)
        }
        .sheet(isPresented: $showNameSheet) {
            AddRecipientSheet(
                email: pendingEmail,
                name: $recipientName,
                isPresented: $showNameSheet,
                onConfirm: addRecipientWithName
            )
        }
        .sheet(isPresented: $showAddSheet) {
            AddRecipientManualSheet(
                email: $addSheetEmail,
                name: $addSheetName,
                isPresented: $showAddSheet,
                onConfirm: addRecipientManual
            )
        }
    }
    
    // MARK: - Actions
    
    private func openNameSheet() {
        let trimmedEmail = currentInput.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedEmail.isEmpty else {
            return
        }
        
        pendingEmail = trimmedEmail
        recipientName = ""
        showNameSheet = true
        currentInput = ""
    }
    
    private func addRecipientWithName() {
        let recipientData = "\(pendingEmail)<\(recipientName)>"
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            recipients.append(recipientData)
            onAddRecipient(recipientData, recipientName)  
        }
        
        showNameSheet = false
        recipientName = ""
        pendingEmail = ""
    }

    private func addRecipientManual() {
        let recipientData = "\(addSheetEmail)<\(addSheetName)>"
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            recipients.append(recipientData)
            onAddRecipient(recipientData, addSheetName)  // ← Passa email<nome>!
        }
        
        showAddSheet = false
        addSheetEmail = ""
        addSheetName = ""
    }
    
    // MARK: - Layout
    private func createRows() -> [RowData] {
        var rows: [RowData] = []
        var currentRow: [ElementData] = []
        var currentRowWidth: CGFloat = 0
        let maxWidth: CGFloat = 300
        
        for (index, email) in recipients.enumerated() {
            let pillWidth = estimatePillWidth(email)
            
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
    let emailData: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(emailData)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(red: 0.25, green: 0.60, blue: 0.50))
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.25, green: 0.60, blue: 0.50))
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

// MARK: - Add Recipient Sheet (con email pre-compilata)
struct AddRecipientSheet: View {
    let email: String
    @Binding var name: String
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    
    var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text(email)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    TextField("Enter recipient name", text: $name)
                        .font(.system(size: 16))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Add Recipient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        isPresented = false
                    }label: {
                     
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        onConfirm()
                        isPresented = false
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(!isNameValid)
                }
            }
        }
    }
}

// MARK: - Add Recipient Manual Sheet (email e nome vuoti)
struct AddRecipientManualSheet: View {
    @Binding var email: String
    @Binding var name: String
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    
    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    TextField("Enter email address", text: $email)
                        .font(.system(size: 16))
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    TextField("Enter recipient name", text: $name)
                        .font(.system(size: 16))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Add Recipient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Label("cancel", systemImage: "xmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onConfirm()
                        isPresented = false
                    } label: {
                        Label("confirm", systemImage: "checkmark")
                        
                    }.disabled(!isFormValid)

                    
                }
            }
        }
    }
}

/*
// MARK: - Preview
#Preview {
    @Previewable @State var toRecipients: [String] = ["adolfo@icloud.com<Adolfo>"]
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
*/
