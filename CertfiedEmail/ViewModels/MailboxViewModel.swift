//
//  MailboxViewModel.swift
//  CertfiedEmail
//
//  ViewModel MVVM della mailbox.
//  Coordina caricamento email, filtri/search e download locale di allegati/certificati.
//


import SwiftUI
import Combine

@MainActor
final class MailboxViewModel: ObservableObject {

    // MARK: - UI State
    @Published var filtersButtonFrame: CGRect = .zero
    @Published var showFiltersMenu = false
    @Published var selectedFilters = "All Inbox"
    @Published var searchText: String = ""
    @Published var isScrolled = false
    @Published var isSearchPresented = false
    @Published var showModal = false

    // MARK: - Data
    @Published var emails: [EmailItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let repository: EmailRepository
    private let fileStorage: FileStorageService
    
    // MARK: - Init
    
    /// Dependency Injection: il ViewModel dipende dal protocollo, non dall'implementazione
    /// Per i test, basta passare un MockEmailRepository
    init(
        repository: EmailRepository = EmailRepositoryImpl(),
        fileStorage: FileStorageService = DefaultFileStorageService()
    ) {
        self.repository = repository
        self.fileStorage = fileStorage
        
        // Carica le email all'avvio
        Task {
            await loadAllEmails()
        }
    }

    // MARK: - Data Loading
    
    /// Carica tutte le email dall'API
    func loadAllEmails() async {
        await loadEmails(resetList: false)
    }
    
    /// Ricarica le email (pull-to-refresh)
    func refreshEmails() async {
        await loadEmails(resetList: true)
    }
    
    // MARK: - Get Single Email Details

    /// Carica i dettagli completi di una singola email
    /// - Parameter id: ID dell'email da caricare
    /// - Returns: EmailItem con tutti i dettagli (attachments, affidavits, etc)
    func getEmailDetails(id: String) async throws -> EmailItem {
        do {
            let detailedEmail = try await repository.getEmail(id: id)
            
            // Aggiorna anche l'email nella lista se esiste
            if let index = emails.firstIndex(where: { $0.id == id }) {
                emails[index] = detailedEmail
            }
            
            return detailedEmail
            
        } catch let repositoryError as RepositoryError {
            throw repositoryError
        } catch {
            throw RepositoryError.unknown
        }
    }
    
    // MARK: - Private Helpers
    
    /// Esegue il caricamento email riusabile tra load iniziale e refresh.
    /// - Parameter resetList: Se `true`, svuota la lista prima del fetch.
    private func loadEmails(resetList: Bool) async {
        guard !isLoading else { return }
        
        isLoading = true
        if resetList {
            emails = []
        }
        errorMessage = nil
        
        do {
            emails = try await repository.getAllEmails()
        } catch let error as RepositoryError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error loading emails"
        }
        
        isLoading = false
    }
    
    // MARK: - Download helpers
    
    /// Decodifica il base64 di un allegato già disponibile in memoria e salva il file in Documents.
    /// - Parameter attachment: Allegato con payload base64.
    /// - Returns: URL locale del file salvato.
    func downloadAttachment(_ attachment: EmailAttachment) async throws -> URL {
        guard let data = decodeBase64Payload(attachment.base64Data) else {
            throw RepositoryError.invalidData
        }
        
        do {
            return try fileStorage.saveToDocuments(data: data, fileName: attachment.filename)
        } catch {
            throw RepositoryError.unknown
        }
    }
    
    /// Decodifica il base64 di un affidavit già disponibile in memoria e salva il PDF in Documents.
    /// - Parameter affidavit: Certificato con payload base64.
    /// - Returns: URL locale del PDF salvato.
    func downloadAffidavit(_ affidavit: Affidavit) async throws -> URL {
        guard let data = decodeBase64Payload(affidavit.bytes) else {
            throw RepositoryError.invalidData
        }
        
        let suggestedName = (affidavit.description ?? "affidavit")
            .replacingOccurrences(of: " ", with: "_")
            .appending(".pdf")
        
        do {
            return try fileStorage.saveToDocuments(data: data, fileName: suggestedName)
        } catch {
            throw RepositoryError.unknown
        }
    }
    
    /// Normalizza e decodifica payload base64 eterogenei (standard/url-safe/data-uri).
    /// - Parameter value: Stringa base64 grezza.
    /// - Returns: `Data` decodificato o `nil` se non valido.
    private func decodeBase64Payload(_ value: String?) -> Data? {
        guard var base64 = value?.trimmingCharacters(in: .whitespacesAndNewlines), !base64.isEmpty else {
            return nil
        }
        
        // Rimuove eventuali virgolette residue serializzate nel payload
        if base64.hasPrefix("\""), base64.hasSuffix("\""), base64.count > 1 {
            base64.removeFirst()
            base64.removeLast()
        }
        
        // Supporta stringhe nel formato "data:...;base64,<payload>"
        if let commaIndex = base64.firstIndex(of: ","), base64[..<commaIndex].contains("base64") {
            base64 = String(base64[base64.index(after: commaIndex)...])
        }
        
        // Supporta base64 URL-safe
        base64 = base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "\\n", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        // Normalizza eventuale padding mancante
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        
        return Data(base64Encoded: base64, options: [.ignoreUnknownCharacters])
    }


    // MARK: - Derived Lists (Filtering & Sorting)

    var filteredEmails: [EmailItem] {
        let filtered: [EmailItem]
        
        switch selectedFilters {
        case "Sent":
            filtered = emails.filter { $0.status == .sent }
        case "Delivered":
            filtered = emails.filter { $0.status == .delivered }
        case "Failed":
            filtered = emails.filter { $0.status == .failed }
        case "Actives":
            filtered = emails.filter { !$0.status.isFinal }
        case "Drafts":
            filtered = emails.filter { $0.status == .draft }
        case "Closed":
            filtered = emails.filter { $0.status == .closed }
        case "All Inbox":
            filtered = emails
        default:
            filtered = emails
        }
        
        // Ordina per ultimo evento (più recenti prima)
        return filtered.sorted { email1, email2 in
            guard let date1 = email1.lastEventDate else { return false }
            guard let date2 = email2.lastEventDate else { return true }
            return date1 > date2
        }
    }

    var searchedEmails: [EmailItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return filteredEmails }

        return filteredEmails.filter { email in
            email.sender.legalName!.localizedCaseInsensitiveContains(query) ||
            email.emailObject.localizedCaseInsensitiveContains(query) ||
            email.sender.emailAddress.localizedCaseInsensitiveContains(query)
        }
    }

    // MARK: - UI Intents

    func setScrolledOffset(_ minY: CGFloat) {
        let shouldBeScrolled = minY < 120

        if shouldBeScrolled != isScrolled {
            isScrolled = shouldBeScrolled

            if isScrolled && showFiltersMenu {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    showFiltersMenu = false
                }
            }
        }
    }

    func dismissFiltersMenu() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showFiltersMenu = false
        }
    }
}
