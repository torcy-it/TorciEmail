//
//  AlertButton.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//

import Foundation

struct AlertButton {
    enum Style {
        case `default`
        case cancel
        case destructive
    }
    
    let title: String
    let style: Style
    let action: () -> Void
}
