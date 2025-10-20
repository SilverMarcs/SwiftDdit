//
//  UserSubredditsView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI

struct UserSubredditsView: View {
    @State private var subreddits: [Subreddit] = []
    @State private var isLoading = false
    @State private var showSettings = false

    var body: some View {
        List {
//            UserLinks()
            Section {
                NavigationLink(value: InboxDestination()) {
                    Label {
                        Text("Inbox")
                    } icon: {
                        Image(systemName: "tray.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
                
                NavigationLink(value: PostFeedType.saved) {
                    Label {
                        Text("Saved")
                    } icon: {
                        Image(systemName: "bookmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            
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
        .contentMargins(.top, 5)
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
        .sheet(isPresented: $showSettings) {
            SettingsView()
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
        }
        #endif
    }
    
    private var groupedSubreddits: [String: [Subreddit]] {
        Dictionary(grouping: subreddits) { subreddit in
            String(subreddit.displayName.prefix(1).uppercased())
        }
    }
    
    private var sortedSectionKeys: [String] {
        groupedSubreddits.keys.sorted()
    }
    
    private func fetchSubreddits() async {
        if let fetchedSubreddits = await RedditAPI.fetchUserSubreddits() {
            subreddits = fetchedSubreddits.filter { $0.isSubscribed }
        }
    }
}
