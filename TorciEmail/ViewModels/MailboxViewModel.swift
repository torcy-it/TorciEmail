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

    // UI state
    @Published var filtersButtonFrame: CGRect = .zero
    @Published var showFiltersMenu = false
    @Published var selectedFilters = "All Inbox"
    @Published var searchText: String = ""
    @Published var isScrolled = false
    @Published var isSearchPresented = false
    @Published var showModal = false

    // Data
    @Published var emails: [EmailItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = VaporAPIService.shared
    
    // MARK: - Init
    
    init() {
        print("📬 MailboxViewModel initialized")
        // Carica le email all'avvio
        Task {
            await loadAllEmails()
        }
    }

    // MARK: - Data Loading
    
    func loadAllEmails() async {
        guard !isLoading else {
            print("⚠️ Already loading, skipping...")
            return
        }
        
        print("📬 Loading ALL emails...")
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.queryAllEviMails()
            
            // Converti EviMail in EmailItem
            emails = response.results.map { EviMailMapper.map($0) }
            
            print("✅ Loaded ALL \(emails.count) emails (total: \(response.totalMatches))")
        } catch let error as APIError {
            errorMessage = error.errorDescription
            print("❌ Failed to load emails: \(error.errorDescription ?? "Unknown error")")
        } catch {
            errorMessage = "Errore nel caricamento delle email"
            print("❌ Failed to load emails: \(error)")
        }
        
        isLoading = false
    }
    
    func refreshEmails() async {
        guard !isLoading else {
            print("Already loading, skipping refresh...")
            return
        }
        
        print("Refreshing emails...")
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.queryAllEviMails()
            emails = response.results.map { EviMailMapper.map($0) }
            print("Refreshed \(emails.count) emails")
        } catch let error as APIError {
            errorMessage = error.errorDescription
            print("Failed to refresh: \(error.errorDescription ?? "Unknown error")")
        } catch {
            errorMessage = "Errore nel refresh delle email"
            print("Failed to refresh: \(error)")
        }
        
        isLoading = false
    }

    // MARK: - Derived lists

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
            filtered = emails.filter { $0.status == .ready }
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

    // MARK: - UI intents

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
