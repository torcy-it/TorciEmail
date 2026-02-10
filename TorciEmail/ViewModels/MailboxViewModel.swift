//
//  MailboxViewModel.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 23/01/26.
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
    
    // MARK: - Init
    
    /// Dependency Injection: il ViewModel dipende dal protocollo, non dall'implementazione
    /// Per i test, basta passare un MockEmailRepository
    init(repository: EmailRepository = EmailRepositoryImpl()) {
        self.repository = repository
        print("MailboxViewModel initialized with repository")
        
        // Carica le email all'avvio
        Task {
            await loadAllEmails()
        }
    }

    // MARK: - Data Loading
    
    /// Carica tutte le email dall'API
    func loadAllEmails() async {
        guard !isLoading else {
            print("Already loading, skipping...")
            return
        }
        
        print("Loading ALL emails via repository...")
        
        isLoading = true
        errorMessage = nil
        
        do {
            emails = try await repository.getAllEmails()
            
            print("Loaded \(emails.count) emails")
        } catch let error as RepositoryError {
            errorMessage = error.errorDescription
            print("Failed to load emails: \(error.errorDescription ?? "Unknown")")
        } catch {
            errorMessage = "Errore nel caricamento delle email"
            print("Unexpected error: \(error)")
        }
        
        isLoading = false
    }
    
    /// Ricarica le email (pull-to-refresh)
    func refreshEmails() async {
        guard !isLoading else {
            print("Already loading, skipping refresh...")
            return
        }
        
        print("Refreshing emails...")
        
        isLoading = true
        errorMessage = nil
        
        do {
            emails = try await repository.getAllEmails()
            print("Refreshed \(emails.count) emails")
        } catch let error as RepositoryError {
            errorMessage = error.errorDescription
            print("Refresh failed: \(error.errorDescription ?? "Unknown")")
        } catch {
            errorMessage = "Errore nel refresh delle email"
            print("Unexpected error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Get Single Email Details

    /// Carica i dettagli completi di una singola email
    /// - Parameter id: ID dell'email da caricare
    /// - Returns: EmailItem con tutti i dettagli (attachments, affidavits, etc)
    func getEmailDetails(id: String) async throws -> EmailItem {
        print("Loading email details for ID: \(id)")
        print("Loading email details for ID: \(id)")
        print("ID type: \(type(of: id))")
        print("ID length: \(id.count)")
        print("ID value: [\(id)]")
        
        do {
            let detailedEmail = try await repository.getEmail(id: id)
            
            // Aggiorna anche l'email nella lista se esiste
            if let index = emails.firstIndex(where: { $0.id == id }) {
                emails[index] = detailedEmail
                print("Updated email in list with full details")
            }
            
            print("Email details loaded successfully")
            print("   - Attachments: \(detailedEmail.attachments.count)")
            print("   - Affidavits: \(detailedEmail.affidavits.count)")
            
            return detailedEmail
            
        } catch let error as RepositoryError {
            print("Failed to load email details: \(error.errorDescription ?? "Unknown")")
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw RepositoryError.unknown
        }
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
