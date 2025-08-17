//
//  UserSubredditsView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI

struct UserSubredditsView: View {
    @Environment(\.appendToPath) var appendToPath
    @State private var subreddits: [Subreddit] = []
    @State private var isLoading = false
    @State private var showSettings = false
    
    @Namespace private var transition

    var body: some View {
        List {
            UserLinks()
            
            if isLoading {
                LoadingIndicator()
                    .id(UUID())
            } else {
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
        }
        .contentMargins(.top, 5)
        .task {
            guard subreddits.isEmpty else { return }
            await fetchSubreddits()
        }
        .refreshable {
            await fetchSubreddits()
        }
        .navigationTitle("Profile")
        .toolbarTitleDisplayMode(.inlineLarge)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .navigationTransition(.zoom(sourceID: "settings-button", in: transition))
                .presentationDetents([.medium])
        }
        #if !os(macOS)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gear")
                }
            }
            .matchedTransitionSource(id: "settings-button", in: transition)
        }
        #endif
    }
    
    // Group subreddits alphabetically
    private var groupedSubreddits: [String: [Subreddit]] {
        Dictionary(grouping: subreddits) { subreddit in
            String(subreddit.displayName.prefix(1).uppercased())
        }
    }
    
    // Get sorted section keys
    private var sortedSectionKeys: [String] {
        groupedSubreddits.keys.sorted()
    }
    
    private func fetchSubreddits() async {
        isLoading = true
        defer { isLoading = false }
        
        if let fetchedSubreddits = await RedditAPI.fetchUserSubreddits() {
            subreddits = fetchedSubreddits.filter { $0.isSubscribed }
        }
    }
}
