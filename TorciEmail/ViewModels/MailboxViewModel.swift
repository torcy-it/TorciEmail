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
    
    // Pagination
    private var currentOffset = 0
    private let pageSize = 50
    private var hasMorePages = true
    private var totalMatches = 0
    
    private let apiService = VaporAPIService.shared
    
    // MARK: - Init
    
    init() {
        print("📬 MailboxViewModel initialized")
        // Carica le email all'avvio
        Task {
            await loadInitialEmails()
        }
    }

    // MARK: - Data Loading
    
    func loadInitialEmails() async {
        guard !isLoading else {
            print("⚠️ Already loading, skipping...")
            return
        }
        
        print("📬 Loading initial emails...")
        
        isLoading = true
        errorMessage = nil
        currentOffset = 0
        hasMorePages = true
        
        do {
            let response = try await apiService.queryEviMails(limit: pageSize, offset: 0)
            
            totalMatches = response.totalMatches
            hasMorePages = response.results.count < response.totalMatches
            currentOffset = response.results.count
            
            // Converti EviMail in EmailItem
            emails = response.results.map { EviMailMapper.map($0) }
            
            print("✅ Loaded \(emails.count) emails (total: \(totalMatches))")
            print("📊 Has more pages: \(hasMorePages)")
        } catch let error as APIError {
            errorMessage = error.errorDescription
            print("❌ Failed to load emails: \(error.errorDescription ?? "Unknown error")")
        } catch {
            errorMessage = "Errore nel caricamento delle email"
            print("❌ Failed to load emails: \(error)")
        }
        
        isLoading = false
    }
    
    func loadMoreEmails() async {
        guard !isLoading, hasMorePages else {
            if !hasMorePages {
                print("ℹ️ No more pages to load")
            }
            return
        }
        
        print("📬 Loading more emails from offset \(currentOffset)...")
        
        isLoading = true
        
        do {
            let response = try await apiService.queryEviMails(
                limit: pageSize,
                offset: currentOffset
            )
            
            hasMorePages = (currentOffset + response.results.count) < totalMatches
            currentOffset += response.results.count
            
            // Aggiungi le nuove email
            let newEmails = response.results.map { EviMailMapper.map($0) }
            emails.append(contentsOf: newEmails)
            
            print("✅ Loaded \(newEmails.count) more emails (total: \(emails.count)/\(totalMatches))")
            print("📊 Has more pages: \(hasMorePages)")
        } catch let error as APIError {
            errorMessage = error.errorDescription
            print("❌ Failed to load more emails: \(error.errorDescription ?? "Unknown error")")
        } catch {
            errorMessage = "Errore nel caricamento"
            print("❌ Failed to load more emails: \(error)")
        }
        
        isLoading = false
    }
    
    func refreshEmails() async {
        print("🔄 Refreshing emails...")
        await loadInitialEmails()
    }

    // MARK: - Derived lists

    var filteredEmails: [EmailItem] {
        switch selectedFilters {
        case "Sent":
            return emails.filter { $0.status == .sent }
        case "Delivered":
            return emails.filter { $0.status == .delivered }
        case "Failed":
            return emails.filter { $0.status == .failed }
        case "Actives":
            return emails.filter { !$0.status.isFinal }
        case "Drafts":
            return emails.filter { $0.status == .ready }
        case "Closed":
            return emails.filter { $0.status == .closed }
        case "All Inbox":
            return emails
        default:
            return emails
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
