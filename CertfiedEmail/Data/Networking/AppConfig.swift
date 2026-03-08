//
//  AppConfig.swift
//  CertfiedEmail
//
//  Centralized runtime configuration loaded from Info.plist.
//

import Foundation

enum AppConfig {
    private static let simulatorDebugBaseURL = "http://localhost:8080"

    static var apiBaseURL: String {
        let configured = (Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let configured, !configured.isEmpty {
            return configured
        }
        
        #if DEBUG
        #if targetEnvironment(simulator)
        return simulatorDebugBaseURL
        #else
        assertionFailure(
            """
            Missing API_BASE_URL for debug build on physical device.
            Set API_BASE_URL in Info.plist to your LAN endpoint, e.g. http://192.168.x.x:8080
            """
        )
        return simulatorDebugBaseURL
        #endif
        #else
        fatalError("Missing API_BASE_URL for Release build.")
        #endif
    }
}
