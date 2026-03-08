//
//  ShareSheet.swift
//  CertfiedEmail
//
//  SwiftUI wrapper for iOS share sheet.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }

    func updateUIViewController(_ : UIActivityViewController, context _: Context) {
        // Intentionally empty: share sheet content is configured at creation time.
    }
}
