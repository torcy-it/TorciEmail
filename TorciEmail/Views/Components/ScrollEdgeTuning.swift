//
//  ScrollEdgeTuning.swift
//  TorciEmail
//
//  ViewModifier condiviso per uniformare effetto bordo scroll.
//


import SwiftUI

/// Applica stile soft allo scroll edge superiore.
struct ScrollEdgeTuning: ViewModifier {
    func body(content: Content) -> some View {
        content.scrollEdgeEffectStyle(.soft, for: .top)
    }
}
