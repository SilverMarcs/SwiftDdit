//
//  SearchTab 2.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var subredditResults: [Subreddit] = []
    @State private var isLoading = false
    
    var body: some View {
        List {
            if isLoading {
                LoadingIndicator()
            }

            ForEach(subredditResults) { subreddit in
                SubredditRowView(subreddit: subreddit)
            }
        }
        .contentMargins(.top, 10)
        .navigationTitle("Search")
        .toolbarTitleDisplayMode(.inlineLarge)
        .searchable(text: $searchText, prompt: "Search Communities")
        .searchPresentationToolbarBehavior(.avoidHidingContent)
        .onSubmit(of: .search) {
            Task {
                await performSearch()
            }
        }
        .onChange(of: searchText) { _, newValue in
            if newValue.isEmpty { subredditResults = [] }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive) {
                    searchText = ""
                    subredditResults = []
                } label: {
//                    Image(systemName: "eraser")
                    Text("Clear")
                }
                .disabled(searchText.isEmpty && subredditResults.isEmpty)
            }
        }
    }
    
    private func performSearch() async {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            subredditResults = []
            return
        }
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        if let subreddits = await RedditAPI.searchSubreddits(searchText, limit: 25) {
            subredditResults = subreddits
        } else {
            subredditResults = []
        }
    }
}
