//
//  SessionExpirationService.swift
//  TorciEmail
//
//  Created by Cursor Refactor on 25/02/26.
//

import Foundation
import Combine

/// Astrazione per l'osservazione della scadenza della sessione
/// in modo da disaccoppiare il ViewModel dall'implementazione concreta dell'API.
protocol SessionExpirationService {
    /// Indica se esiste una sessione autenticata a livello di API.
    var isAuthenticated: Bool { get }
    
    /// Publisher che notifica quando la sessione è scaduta.
    var sessionExpiredPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Resetta il flag di sessione scaduta (tipicamente quando l'utente chiude l'alert).
    func resetSessionExpiredFlag()
}

/// Implementazione di default che usa `VaporAPIService.shared`.
final class DefaultSessionExpirationService: SessionExpirationService {
    private let apiService: VaporAPIService
    
    init(apiService: VaporAPIService = .shared) {
        self.apiService = apiService
    }
    
    var isAuthenticated: Bool {
        apiService.isAuthenticated
    }
    
    var sessionExpiredPublisher: AnyPublisher<Bool, Never> {
        apiService.$sessionExpired.eraseToAnyPublisher()
    }
    
    func resetSessionExpiredFlag() {
        apiService.sessionExpired = false
    }
}

