//
//  ButtonFrameKey.swift
//  CertfiedEmail
//
//  PreferenceKey per propagare il frame del bottone filtri.
//


import SwiftUI

/// Chiave preferenza usata per ancorare overlay alla posizione del bottone.
struct ButtonFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}