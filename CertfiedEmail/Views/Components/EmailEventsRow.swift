//
//  EmailEventsView.swift
//  CertfiedEmail
//
//  Componente sintetico stato eventi.
//  Mostra le tre icone invio/lettura/contenuto nella mailbox.
//

import SwiftUI

/// Riga compatta con i tre stati principali del ciclo di vita email.
struct EmailEventsRow: View {
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

/// Singola icona evento con tint dinamico.
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
        EmailEventsRow(eventStatus: EmailEventStatus(
            sendingStatus: .waiting,
            readingStatus: .waiting,
            contentStatus: .waiting
        ))
        
        Divider()
        
        Text("Email inviata")
        EmailEventsRow(eventStatus: EmailEventStatus(
            sendingStatus: .sent,
            readingStatus: .waiting,
            contentStatus: .waiting
        ))
        
        Divider()
        
        Text("Email vista")
        EmailEventsRow(eventStatus: EmailEventStatus(
            sendingStatus: .sent,
            readingStatus: .opened,
            contentStatus: .waiting
        ))
        
        Divider()
        
        Text("Contenuto accettato")
        EmailEventsRow(eventStatus: EmailEventStatus(
            sendingStatus: .sent,
            readingStatus: .opened,
            contentStatus: .accepted
        ))
        
        Divider()
        
        Text("Invio fallito")
        EmailEventsRow(eventStatus: EmailEventStatus(
            sendingStatus: .failed,
            readingStatus: .waiting,
            contentStatus: .waiting
        ))
    }
    .padding()
}
