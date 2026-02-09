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
            email.senderName.localizedCaseInsensitiveContains(query) ||
            email.emailObject.localizedCaseInsensitiveContains(query) ||
            email.emailDescription.localizedCaseInsensitiveContains(query)
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
