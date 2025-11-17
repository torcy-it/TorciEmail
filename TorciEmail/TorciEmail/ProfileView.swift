import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showingImagePicker = false
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            Color.black.ignoresSafeArea()
            
       
            ScrollView {
                
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollOffsetKey.self,
                        value: geo.frame(in: .named("scroll")).minY
                    )
                }
                .frame(height: 0)
                
                VStack(spacing: 0) {
                    
                  
                    VStack(spacing: 20) {
                        
                        Spacer().frame(height: 80)
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            ZStack(alignment: .bottomTrailing) {

                            
                                if let uiImage = UIImage(named: "watermelon") {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(Color.white.opacity(0.3), lineWidth: 2)
                                        )
                                } else {
                              
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.purple, .pink],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Text("N/D")
                                                .font(.system(size: 45, weight: .medium))
                                                .foregroundColor(.white)
                                        )
                                        .overlay(
                                            Circle().stroke(Color.white.opacity(0.3), lineWidth: 2)
                                        )
                                }

                               
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                    )
                            }

                        }
                        
                        VStack(spacing: 6) {
                            Text("Adolfo")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("torci@icloud.com")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(.bottom, 40)
                    
                    
                    // ---------- SECTIONS ----------
                    VStack(spacing: 16) {
                        
                        glassSection {
                            glassMenuItem(icon: "person.circle", title: "Manage Account")
                            glassDivider()
                            glassMenuItem(icon: "arrow.left.arrow.right.circle", title: "Switch Account")
                            glassDivider()
                            glassMenuItem(icon: "plus.circle", title: "Add Account")
                        }
                        
                        glassSection {
                            HStack(spacing: 18) {
                                Image(systemName: "icloud.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white.opacity(0.85))
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("iCloud Storage")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("2.85 GB of 15 GB used")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white.opacity(0.55))
                                }
                                
                                Spacer()
                                
                                Text("19%")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                        }
                        
                        glassSection {
                            glassMenuItem(icon: "bell", title: "Notifications")
                            glassDivider()
                            glassMenuItem(icon: "lock", title: "Privacy & Security")
                            glassDivider()
                            glassMenuItem(icon: "paintbrush", title: "Appearance")
                        }
                        
                        glassSection {
                            glassMenuItem(icon: "info.circle", title: "Help & Feedback")
                            glassDivider()
                            glassMenuItem(icon: "doc.text", title: "Terms of Service")
                            glassDivider()
                            glassMenuItem(icon: "hand.raised", title: "Privacy Policy")
                        }
                        
                        Button(action: {}) {
                            Text("Sign Out")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.red.opacity(0.4), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        
                    }
                    .padding(.bottom, 150)
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetKey.self) { scrollOffset = $0 }
            
            
            Button(action: { dismiss() }) {
                backButton
            }
            .padding(.leading, 20)
            .padding(.top, 8)
            .zIndex(2)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    private var backButton: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .opacity(0.25)
            
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
            
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: 40, height: 40)
    }
    
    private func glassMenuItem(icon: String, title: String) -> some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
    
    private func glassDivider() -> some View {
        Divider()
            .background(Color.white.opacity(0.1))
            .padding(.leading, 60)
    }
    
    private func glassSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(glassBackground())
        .padding(.horizontal, 20)
    }
    
    private func glassBackground() -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 17/255, green: 24/255, blue: 39/255))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
            )
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
