//
//  CertificateProfile.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 24/01/26.
//


//
//  CertificateProfile.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 16/11/25.
//

import Foundation

// MARK: - Certificate Profile
struct CertificateProfile: Codable, Hashable {
    let level: CertificationLevel
    let features: [String]
    let deliveryMode: DeliveryMode?
    
    enum CertificationLevel: String, Codable {
        case basic = "Basic"
        case standard = "Standard"
        case advanced = "Advanced"
        case allEvent = "AllEvent"
        case allEventPlusClose = "AllEventPlusClose"
    }
    
    enum DeliveryMode: String, Codable {
        case forward = "Forward"
        case notify = "Notify"
    }
}