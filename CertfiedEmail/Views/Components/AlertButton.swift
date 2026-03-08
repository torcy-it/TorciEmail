//
//  AlertButton.swift
//  CertfiedEmail
//
//  Modello dati per i pulsanti del custom alert.
//

import Foundation

/// Configurazione di un bottone all'interno di `CustomAlert`.
struct AlertButton {
    enum Style {
        case primary
        case cancel
        case destructive
    }
    
    let title: String
    let style: Style
    let action: () -> Void
}
