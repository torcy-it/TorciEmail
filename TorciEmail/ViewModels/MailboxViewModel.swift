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
    @Published var emails: [EmailItem] =  [] // per ora mock

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
        // la tua logica: scrolled se minY < 120
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
