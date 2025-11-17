import SwiftUI


struct ButtonFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ContentView: View {
    
    @State private var categoriesButtonFrame: CGRect = .zero
    @State private var showCategoriesMenu = false
    @State private var showFiltersModal = false
    @State private var selectedCategory = "All Inbox"
    
    @State private var emails: [EmailItem] = [
        EmailItem(senderName: "Sender Name", emailObject: "Email Object",
                  emailDescription: "Email Description", date: "dd/mm/yy", isRead: false),
        EmailItem(senderName: "Sender Name", emailObject: "Email Object",
                  emailDescription: "Email Description", date: "dd/mm/yy", isRead: false),
        EmailItem(senderName: "Sender Name", emailObject: "Email Object",
                  emailDescription: "Email Description", date: "dd/mm/yy", isRead: false),
        EmailItem(senderName: "Sender Name", emailObject: "Email Object",
                  emailDescription: "Email Description", date: "dd/mm/yy", isRead: false),
        EmailItem(senderName: "Sender Name", emailObject: "Email Object",
                  emailDescription: "Email Description", date: "dd/mm/yy", isRead: false)
    ]
    
    @State private var searchText = ""

    
    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                

                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    header
                    
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(emails) { email in
                                EmailRowView(email: email)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                    }
                    
               
                    BottomBar(
                        searchText: $searchText,
                        onFilterTap: {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                                showFiltersModal = true
                            }
                        }
                    )
                }
                
                
  
                if showCategoriesMenu {
                    
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                showCategoriesMenu = false
                            }
                        }
                        .transition(.opacity)
                        .zIndex(10)
                    
                    CategoriesMenu(
                        selectedCategory: $selectedCategory,
                        showMenu: $showCategoriesMenu
                    )
                    .frame(width: 260)
                    .offset(
                        x: categoriesButtonFrame.midX - 10,
                        y: categoriesButtonFrame.maxY + 78
                    )
                    .scaleEffect(showCategoriesMenu ? 1 : 0.1, anchor: .topTrailing)
                    .opacity(showCategoriesMenu ? 1 : 0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.5),
                        value: showCategoriesMenu
                    )
                    .zIndex(20)
                }
                
                
     
                if showFiltersModal {
                    
        
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                                showFiltersModal = false
                            }
                        }
                        .zIndex(30)
                    
   
                    FiltersModal(isVisible: $showFiltersModal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(40)
                }
            }
            .coordinateSpace(name: "root")
            .onPreferenceChange(ButtonFrameKey.self) { value in
                categoriesButtonFrame = value
            }
        }
    }

    

    var header: some View {
        VStack(spacing: 12) {
            
            HStack {
                glassCapsuleButton("Select")
                Spacer()
                ProfileButton()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedCategory)
                        .foregroundColor(.white)
                        .font(.system(size: 36, weight: .bold))
                    
                    Text("Update Just Now")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 16))
                }
                
                Spacer()
                
                CategoriesButton(showMenu: $showCategoriesMenu)
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ButtonFrameKey.self,
                                value: proxy.frame(in: .named("root"))
                            )
                        }
                    )
            }
            .padding(.horizontal)
        }
    }
    
    
    func glassCapsuleButton(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.white)
            .font(.system(size: 17, weight: .semibold))
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
            )
    }
}

#Preview {
    ContentView()
}
