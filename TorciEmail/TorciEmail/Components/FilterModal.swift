import SwiftUI
import SwiftUI

struct FiltersModal: View {

    @Binding var isVisible: Bool

    @GestureState private var dragOffset: CGFloat = 0
    @State private var currentOffset: CGFloat = 0

    @State private var includeUnread = false
    @State private var includeAttachments = false
    @State private var sendToMe = false
    @State private var sendCcMe = false
    @State private var fromDate = Date()
    @State private var toDate = Date()
    @State private var pressedItem: String? = nil

    var body: some View {

        ZStack {

       
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { closeModal() }

   
            VStack(spacing: 0) {

             
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.white.opacity(0.30))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 10)

    
                modalContent
            }
            .background(Color(hex: "1A1A1A"))
            .clipShape(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
            )
            .offset(y: currentOffset + dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if value.translation.height > 0 {
                            state = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 120 {
                            closeModal()
                        } else {
                            withAnimation(.spring()) {
                                currentOffset = 0
                            }
                        }
                    }
            )
            .ignoresSafeArea(edges: .bottom)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentOffset)
    }


    private var modalContent: some View {

        VStack(spacing: 24) {

         
            HStack {
                Spacer()

                Button(action: closeModal) {
                    Circle()
                        .fill(Color.black)
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.28), lineWidth: 1)
                        )
                        .frame(width: 42, height: 42)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        )
                }
                .buttonStyle(.plain)
            }
            .overlay(
                Text("Filters")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            )
            .padding(.horizontal)

        
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {

                    sectionTitle("Include")
                    card {
                        selectableRow(icon: "envelope.badge", title: "Unread", isOn: $includeUnread)
                        filterDivider
                        selectableRow(icon: "paperclip", title: "With attachment", isOn: $includeAttachments)
                    }

                    sectionTitle("Send to")
                    card {
                        selectableRow(icon: "rectangle.and.pencil.and.ellipsis", title: "To: Me", isOn: $sendToMe)
                        filterDivider
                        selectableRow(icon: "rectangle.and.pencil.and.ellipsis", title: "Cc: Me", isOn: $sendCcMe)
                    }

                    sectionTitle("Range by date")
                    card {
                        dateRow(title: "From:", date: $fromDate)
                        filterDivider
                        dateRow(title: "To:", date: $toDate)
                    }

                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .padding(.bottom, 10)
    }



    private func closeModal() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            isVisible = false
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 22, weight: .semibold))
            .foregroundColor(.white.opacity(0.75))
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(Color(red: 17/255, green: 24/255, blue: 39/255))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
            )
    }

    private func selectableRow(icon: String, title: String, isOn: Binding<Bool>) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            pressedItem = title
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring()) {
                    isOn.wrappedValue.toggle()
                    pressedItem = nil
                }
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                Text(title)
                Spacer()
                if isOn.wrappedValue {
                    Image(systemName: "checkmark")
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(pressedItem == title ? 0.10 : 0))
            .scaleEffect(pressedItem == title ? 0.96 : 1)
        }
        .buttonStyle(.plain)
    }


    private func dateRow(title: String, date: Binding<Date>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))

            Spacer()

            DatePicker("", selection: date, displayedComponents: .date)
                .labelsHidden()
                .tint(.white)
                .datePickerStyle(.compact)
                .colorScheme(.dark)
        }
        .padding(.vertical, 6)
    }



    private var filterDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.20))
            .frame(height: 1)
            .padding(.leading, 40)
    }
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF)/255
        let g = Double((rgb >> 8) & 0xFF)/255
        let b = Double(rgb & 0xFF)/255
        self.init(red: r, green: g, blue: b)
    }
}



#Preview {
    FiltersModal(isVisible: .constant(true))
        .preferredColorScheme(.dark)
}
