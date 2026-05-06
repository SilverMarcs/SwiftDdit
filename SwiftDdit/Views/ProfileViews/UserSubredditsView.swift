//
//  UserSubredditsView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI

struct UserSubredditsView: View {
    @State private var credentialsManager = CredentialsManager.shared
    @State private var subreddits: [Subreddit] = []
    @State private var isLoading = false
    @State private var searchText = ""

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
            } else if credentialsManager.activeCredentialId == nil {
                ContentUnavailableView(
                    "No Account Connected",
                    systemImage: "person.crop.circle.badge.exclamationmark",
                    description: Text("Go to Settings > Credentials to add an account first")
                )
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
        #if !os(macOS)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: SettingsDestination()) {
                    Image(systemName: "gear")
                }
            }
        }
        #endif
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
}
