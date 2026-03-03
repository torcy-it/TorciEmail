//
//  AppConfig.swift
//  CertfiedEmail
//
//  Centralized runtime configuration loaded from Info.plist.
//

import Foundation

enum AppConfig {
    private static let defaultBaseURL = "http://localhost:8080"

    static var apiBaseURL: String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String else {
            return defaultBaseURL
        }

        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return normalized.isEmpty ? defaultBaseURL : normalized
    }
}
