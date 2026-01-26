//
//  ScrollEdgeTuning.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 23/01/26.
//


import SwiftUI

struct ScrollEdgeTuning: ViewModifier {
    func body(content: Content) -> some View {
        content.scrollEdgeEffectStyle(.soft, for: .top)
    }
}
