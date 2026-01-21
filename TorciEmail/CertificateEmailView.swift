

//
//  SelectRow.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 21/01/26.
//


import SwiftUI


struct CertificateEmailView: View {

    // Selection
    @State private var selectedCertifiedTitle: String = "EviMail"
    @State private var selectedTypeTitle: String = "My EviMail"
    @Binding var showEmailInfoModal: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 28) {

            }
            .padding(.horizontal, 18)
            .toolbar {
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        showDetailsModal.toggle()
                        
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



#Preview {
    DetailsEmailView( showDetailsModal: .constant(true))
    
}
