//
//  MailboxView.swift
//  CertfiedEmail
//
//  Vista principale mailbox.
//  Mostra elenco email, ricerca, filtri e navigazione ai dettagli.
//

import SwiftUI

/// Schermata iniziale utente autenticato con lista EviMail.
struct MailboxView: View {

    @StateObject private var mailVm = MailboxViewModel()
    @EnvironmentObject var authVm: AuthViewModel

    /// Renderizza la mailbox con stati caricamento/errore/vuoto e contenuto.
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {

                            header

                            VStack(spacing: 14) {
                                // Stato caricamento
                                if mailVm.isLoading && mailVm.emails.isEmpty {
                                    loadingView
                                }
                                // Stato errore
                                else if let errorMessage = mailVm.errorMessage, mailVm.emails.isEmpty {
                                    errorView(errorMessage)
                                }
                                // Stato vuoto
                                else if mailVm.searchedEmails.isEmpty {
                                    emptyState
                                }
                                // Lista email
                                else {
                                    ForEach(mailVm.searchedEmails) { email in
                                        NavigationLink(value: email) {
                                            EmailRow(email: email)
                                                .padding(.horizontal)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .navigationDestination(for: EmailItem.self) { email in
                                        EmailView(email: email)
                                            .environmentObject(mailVm)
                                    }
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding(.top, 8)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .refreshable {
                        _ = Task {
                            await mailVm.refreshEmails()
                        }
                        
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 secondi
                    }                }
                .toolbar { toolbar }
                .navigationBarTitleDisplayMode(.inline)
                .searchable(
                    text: $mailVm.searchText,
                    isPresented: $mailVm.isSearchPresented,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search emails"
                )
                .modifier(ScrollEdgeTuning())
                .sheet(isPresented: $mailVm.showModal) {
                    CategoriesView(showModal: $mailVm.showModal)
                }

                filtersOverlay
            }
            .onPreferenceChange(ButtonFrameKey.self) { value in
                mailVm.filtersButtonFrame = value
            }
        }
    }

    // MARK: - Header

    /// Header con titolo, ultimo aggiornamento e bottone filtri.
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("EviMail")
                    .foregroundColor(.black)
                    .font(.system(size: 40, weight: .semibold))
                    .opacity(mailVm.isScrolled ? 0 : 1)
                    .animation(.easeInOut(duration: 0.2), value: mailVm.isScrolled)

                Text(updateText)
                    .foregroundColor(.black.opacity(0.5))
                    .font(.system(size: 16))
            }

            Spacer()

            FiltersButton(showMenu: $mailVm.showFiltersMenu, selectedFilter: $mailVm.selectedFilters)
                .disabled(mailVm.isScrolled)
                .allowsHitTesting(!mailVm.isScrolled)
                .opacity(mailVm.isScrolled ? 0.5 : 1)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ButtonFrameKey.self,
                            value: proxy.frame(in: .global)
                        )
                    }
                )
        }
        .padding(.horizontal, 13)
        .padding(.top, 8)
        .background(
            GeometryReader { geo in
                let offset = geo.frame(in: .global).minY
                Color.clear
                    .onChange(of: offset) { _, newValue in
                        mailVm.setScrolledOffset(newValue)
                    }
            }
        )
    }
    
    private var updateText: String {
        if mailVm.isLoading {
            return "Caricamento..."
        }
        return "Update Just Now"
    }

    // MARK: - Vista Caricamento
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Caricamento email...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.top, 60)
    }
    
    // MARK: - Vista Errore
    
    /// Mostra errore di caricamento con azione di retry.
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Errore nel caricamento email")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                Task {
                    await mailVm.refreshEmails()
                }
            } label: {
                Text("Riprova")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .padding(.top, 60)
    }

    // MARK: - Vista Vuota

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("Nessuna email trovata")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.top, 60)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if mailVm.isScrolled {
                Text("EviMail")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink(destination: ProfileView()) {
                VStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.black.opacity(0.7))
                        .frame(width: 50, height: 48)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(
                            color: .black.opacity(0.25),
                            radius: 2,
                            x: 0,
                            y: 4
                        )
                    
                    Text(String(authVm.userEmail.prefix { $0 != "@" }))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black.opacity(0.7))
                        .lineLimit(1)
                }
            }
            .buttonStyle(.plain)
        }
        .sharedBackgroundVisibility(.hidden)

        DefaultToolbarItem(kind: .search, placement: .bottomBar)

        ToolbarSpacer(.fixed, placement: .bottomBar)

        ToolbarItem(placement: .bottomBar) {
            NavigationLink {
                EviMailComposeView(fromEmail: authVm.userEmail)
                
            } label: {
                Image(systemName: "square.and.pencil")
            }
        }

        ToolbarSpacer(.fixed, placement: .bottomBar)

        ToolbarItem(placement: .bottomBar) {
            Button {
                mailVm.showModal.toggle()
            } label: {
                Image(systemName: "rectangle.3.group.bubble")
            }
        }
    }

    // MARK: - Filters overlay

    /// Overlay per menu filtri ancorato al bottone in header.
    @ViewBuilder
    private var filtersOverlay: some View {
        if mailVm.showFiltersMenu {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .allowsHitTesting(true)
                .onTapGesture { mailVm.dismissFiltersMenu() }
                .transition(.opacity)
                .zIndex(10)

            FiltersMenu(
                selectedFilters: $mailVm.selectedFilters,
                showMenu: $mailVm.showFiltersMenu
            )
            .offset(
                x: mailVm.filtersButtonFrame.minX - 10,
                y: mailVm.filtersButtonFrame.maxY + 84
            )
            .scaleEffect(mailVm.showFiltersMenu ? 1 : 0.95, anchor: .top)
            .opacity(mailVm.showFiltersMenu ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.5), value: mailVm.showFiltersMenu)
            .zIndex(20)
        }
    }
}
