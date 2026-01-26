//
//  ButtonFrameKey.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 23/01/26.
//


import SwiftUI

struct ButtonFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}