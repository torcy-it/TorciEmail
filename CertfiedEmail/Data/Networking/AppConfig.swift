//
//  AppConfig.swift
//  CertfiedEmail
//
//  Centralized runtime configuration loaded from Info.plist.
//

import Foundation

enum AppConfig {
    private static let simulatorDebugBaseURL = "http://localhost:8080"
    #if DEBUG
    private static let debugOverrideKey = "debug.apiBaseURLOverride"
    #endif

    static var apiBaseURL: String {
        #if DEBUG
        if let override = debugBaseURLOverride {
            return override
        }
        #endif
        
        let configured = (Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let configured, !configured.isEmpty {
            return configured
        }
        
        #if DEBUG
        #if targetEnvironment(simulator)
        return simulatorDebugBaseURL
        #else
        print(
            """
            [AppConfig] Missing API_BASE_URL for debug build on physical device.
            Using localhost fallback. Set a reachable LAN endpoint from Debug Server UI.
            """
        )
        return simulatorDebugBaseURL
        #endif
        #else
        fatalError("Missing API_BASE_URL for Release build.")
        #endif
    }
    
    #if DEBUG
    static var debugBaseURLOverride: String? {
        guard let raw = UserDefaults.standard.string(forKey: debugOverrideKey) else {
            return nil
        }
        let normalized = normalize(raw)
        return normalized.isEmpty ? nil : normalized
    }
    
    static func setDebugBaseURLOverride(_ value: String) {
        let normalized = normalize(value)
        if normalized.isEmpty {
            UserDefaults.standard.removeObject(forKey: debugOverrideKey)
        } else {
            UserDefaults.standard.set(normalized, forKey: debugOverrideKey)
        }
    }
    
    static func clearDebugBaseURLOverride() {
        UserDefaults.standard.removeObject(forKey: debugOverrideKey)
    }
    
    static func defaultConfiguredBaseURLForDebugDisplay() -> String {
        let configured = (Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let configured, !configured.isEmpty {
            return normalize(configured)
        }
        return simulatorDebugBaseURL
    }
    
    private static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/+$", with: "", options: .regularExpression)
    }
    #endif
}
