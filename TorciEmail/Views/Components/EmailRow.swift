//
//  EmailRowView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//
import SwiftUI


struct EmailRow: View {
    let email: EmailItem

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 4) {  // Spacing minimo di 4px

                VStack(alignment: .leading, spacing: 8) {
                    Text(email.senderName)
                        .font(.system(size: 22, weight: .semibold))
                        .lineLimit(1)
                        

                    Text(email.emailObject)
                        .font(.system(size: 20, weight: .regular))
                        .lineLimit(1)

                    Text(email.emailDescription)
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
     

                    EmailEventsView(eventStatus: email.eventStatus)
                    
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
                .fixedSize(horizontal: true, vertical: false)  // Non comprimere la parte destra
            }
            .padding(.vertical, 16)
            

            Divider()
                
        }
    }

    private func statusIcon(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .regular))
    }
    
    private func eventIcon(_ eventItem: EmailEvent) -> some View {
        let color = eventItem.event.tint(for: eventItem.state).opacity( 0.80)
        let iconName = eventItem.event.assetName(for: eventItem.state)
        
        return Image(iconName)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 29, height: 24)
            .foregroundColor(color)
    }
}

#Preview {
    MailboxView()
}
