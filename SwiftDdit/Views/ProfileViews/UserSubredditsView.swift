//
//  UserSubredditsView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI

struct UserSubredditsView: View {
    @Environment(SettingsNavigationCoordinator.self) private var settingsNavigation
    @State private var subreddits: [Subreddit] = []
    @State private var isLoading = false
    @State private var searchText = ""

    @Namespace private var transition

    var body: some View {
        List {
            UserLinks()

            ForEach(sortedSectionKeys, id: \.self) { letter in
                Section(letter) {
                    if let subredditsInSection = groupedSubreddits[letter] {
                        ForEach(subredditsInSection.sorted { $0.displayName < $1.displayName }, id: \.id) { subreddit in
                            SubredditRowView(subreddit: subreddit)
                        }
                    }
                }
                .sectionIndexLabel(letter)
            }
        }
        .overlay {
            if isLoading {
                LoadingIndicator()
            }
        }
        .searchable(text: Binding(
            get: { searchText },
            set: { newValue in
                withAnimation {
                    searchText = newValue
                }
            }
        ), prompt: "Filter subreddits")
        .task {
            guard subreddits.isEmpty else { return }
            isLoading = true
            await fetchSubreddits()
            isLoading = false
        }
        .refreshable {
            await fetchSubreddits()
        }
        .navigationTitle("Profile")
        .toolbarTitleDisplayMode(.inlineLarge)
        .sheet(item: settingsSheetBinding) { sheet in
            switch sheet {
            case .settings:
                SettingsView()
                #if !os(macOS)
                    .navigationTransition(.zoom(sourceID: "settings-gear", in: transition))
                #endif
            }
        }
        #if !os(macOS)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: openSettings) {
                    Image(systemName: "gear")
                }
            }
            .matchedTransitionSource(id: "settings-gear", in: transition)
        }
        #endif
    }

    private var settingsSheetBinding: Binding<SettingsNavigationCoordinator.SheetDestination?> {
        Binding(
            get: { settingsNavigation.presentedSheet },
            set: { newValue in
                if newValue == nil {
                    settingsNavigation.dismissSettings()
                }
            }
        )
    }

    private var groupedSubreddits: [String: [Subreddit]] {
        let filtered = searchText.isEmpty ? subreddits : subreddits.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
        return Dictionary(grouping: filtered) { subreddit in
            String(subreddit.displayName.prefix(1).uppercased())
        }
    }

    private var sortedSectionKeys: [String] {
        groupedSubreddits.keys.sorted()
    }

    private func fetchSubreddits() async {
        if let fetchedSubreddits = await RedditAPI.fetchUserSubreddits() {
            withAnimation(.smooth) {
                subreddits = fetchedSubreddits.filter { $0.isSubscribed }
            }
        }
    }

    private func openSettings() {
        settingsNavigation.presentSettings()
    }
}
