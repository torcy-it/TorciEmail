//
//  EmailEventsView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 04/02/26.
//

import SwiftUI

struct EmailEventsView: View {
    let eventStatus: EmailEventStatus
    
    var body: some View {
        HStack(spacing: 2) {
            // ICONA 1: INVIO
            EventIconView(
                assetName: eventStatus.sendingStatus.assetName,
                tint: eventStatus.sendingStatus.tint
            )
            
            // ICONA 2: LETTURA
            EventIconView(
                assetName: eventStatus.readingStatus.assetName,
                tint: eventStatus.readingStatus.tint
            )
            
            // ICONA 3: CONTENUTO
            EventIconView(
                assetName: eventStatus.contentStatus.assetName,
                tint: eventStatus.contentStatus.tint
            )
        }
    }
}

// Vista singola icona
struct EventIconView: View {
    let assetName: String
    let tint: Color
    
    var body: some View {
        Image(assetName)
            .resizable()
            .renderingMode(.template)  
            .aspectRatio(contentMode: .fit)
            .frame(width: 28, height: 28)
            .foregroundStyle(tint)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Idle - tutto in waiting")
        EmailEventsView(eventStatus: EmailEventStatus(
            sendingStatus: .waiting,
            readingStatus: .waiting,
            contentStatus: .waiting
        ))
        
        Divider()
        
        Text("Email inviata")
        EmailEventsView(eventStatus: EmailEventStatus(
            sendingStatus: .sent,
            readingStatus: .waiting,
            contentStatus: .waiting
        ))
        
        Divider()
        
        Text("Email vista")
        EmailEventsView(eventStatus: EmailEventStatus(
            sendingStatus: .sent,
            readingStatus: .opened,
            contentStatus: .waiting
        ))
        
        Divider()
        
        Text("Contenuto accettato")
        EmailEventsView(eventStatus: EmailEventStatus(
            sendingStatus: .sent,
            readingStatus: .opened,
            contentStatus: .accepted
        ))
        
        Divider()
        
        Text("Invio fallito")
        EmailEventsView(eventStatus: EmailEventStatus(
            sendingStatus: .failed,
            readingStatus: .waiting,
            contentStatus: .waiting
        ))
    }
    .padding()
}
