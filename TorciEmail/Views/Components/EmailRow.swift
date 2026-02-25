//
//  EmailRowView.swift
//  TorciEmail
//
//  Cella riga mailbox.
//  Mostra mittente, oggetto, estratto, stato e icone evento.
//
import SwiftUI


/// Componente riga singola nella lista email.
struct EmailRow: View {
    let email: EmailItem

    /// Renderizza il contenuto sintetico della email.
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 4) {

                VStack(alignment: .leading, spacing: 8) {
                    Text(email.sender.legalName ?? "Unknown")
                        .font(.system(size: 22, weight: .semibold))
                        .lineLimit(1)
                        

                    Text(email.emailObject)
                        .font(.system(size: 20, weight: .regular))
                        .lineLimit(1)

                    Text(email.bodyPlainText)
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        
                        
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: 10) {

                    Text(email.date)
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 4)
     

                    EmailEventsRow(eventStatus: email.eventStatus)
                    
                    Text(email.status.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 100, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(email.status.badgeBackground)
                                .opacity(0.30)
                        )
                    
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.vertical, 16)
            

            Divider()
                
        }
    }

}

#Preview {
    MailboxView()
}
