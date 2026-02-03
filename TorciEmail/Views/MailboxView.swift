//
//  MailboxView.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 23/01/26.
//


import SwiftUI

struct MailboxView: View {

    @StateObject private var vm = MailboxViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {

                            header

                            VStack(spacing: 14) {
                                if vm.searchedEmails.isEmpty {
                                    emptyState
                                } else {
                                    ForEach(vm.searchedEmails) { email in
                                        NavigationLink(value: email) {
                                            EmailRow(email: email)
                                                .padding(.horizontal)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .navigationDestination(for: EmailItem.self) { email in
                                        EmailView(email: email)
                                    }
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding(.top, 8)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
                .toolbar { toolbar }
                .searchable(
                    text: $vm.searchText,
                    isPresented: $vm.isSearchPresented,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search emails"
                )
                .modifier(ScrollEdgeTuning())
                .sheet(isPresented: $vm.showModal) {
                    CategoriesView(showModal: $vm.showModal)
                }

                filtersOverlay
            }
            .onPreferenceChange(ButtonFrameKey.self) { value in
                vm.filtersButtonFrame = value
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("EviMail")
                    .foregroundColor(.black)
                    .font(.system(size: 40, weight: .semibold))

                Text("Update Just Now")
                    .foregroundColor(.black.opacity(0.5))
                    .font(.system(size: 16))
            }

            Spacer()

            FiltersButton(showMenu: $vm.showFiltersMenu, selectedFilter: $vm.selectedFilters)
                .disabled(vm.isScrolled)
                .allowsHitTesting(!vm.isScrolled)
                .opacity(vm.isScrolled ? 0.5 : 1)
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
                        vm.setScrolledOffset(newValue)
                    }
            }
        )
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No emails found")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.top, 60)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { } label: {
                Text("select")
                    .frame(width: 100, height: 48)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            ProfileButton()
                .buttonStyle(.plain)
        }
        .sharedBackgroundVisibility(.hidden)

        DefaultToolbarItem(kind: .search, placement: .bottomBar)

        ToolbarSpacer(.fixed, placement: .bottomBar)

        ToolbarItem(placement: .bottomBar) {
            Button { } label: {
                Image(systemName: "square.and.pencil")
            }
        }

        ToolbarSpacer(.fixed, placement: .bottomBar)

        ToolbarItem(placement: .bottomBar) {
            Button {
                vm.showModal.toggle()
            } label: {
                Image(systemName: "rectangle.3.group.bubble")
            }
        }
    }

    // MARK: - Filters overlay

    @ViewBuilder
    private var filtersOverlay: some View {
        if vm.showFiltersMenu {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .allowsHitTesting(true)
                .onTapGesture { vm.dismissFiltersMenu() }
                .transition(.opacity)
                .zIndex(10)

            FiltersMenu(
                selectedFilters: $vm.selectedFilters,
                showMenu: $vm.showFiltersMenu
            )
            .offset(
                x: vm.filtersButtonFrame.minX - 10,
                y: vm.filtersButtonFrame.maxY + 84
            )
            .scaleEffect(vm.showFiltersMenu ? 1 : 0.95, anchor: .top)
            .opacity(vm.showFiltersMenu ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.5), value: vm.showFiltersMenu)
            .zIndex(20)
        }
    }
}
