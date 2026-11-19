//
//  FilteredContentView.swift
//  SwiftDdit
//
//  Created by Kgirthofer on 03/11/2026.
//

import SwiftUI

/// Lists the subreddits and users hidden from feeds, with swipe-to-delete to
/// unfilter them.
struct FilteredContentView: View {
    @State private var filters = FilterManager.shared

    var body: some View {
        Form {
            if filters.filteredSubreddits.isEmpty && filters.filteredUsers.isEmpty {
                ContentUnavailableView(
                    "No Filters",
                    systemImage: "line.3.horizontal.decrease.circle",
                    description: Text("Long-press a post to filter its subreddit or author from your feeds.")
                )
            }

            if !filters.filteredSubreddits.isEmpty {
                Section {
                    ForEach(filters.filteredSubreddits, id: \.self) { name in
                        Label("r/\(name)", systemImage: "r.circle")
                    }
                    .onDelete { offsets in
                        filters.removeSubreddits(atOffsets: offsets)
                    }
                } header: {
                    Text("Subreddits")
                } footer: {
                    Text("Posts from these subreddits are hidden everywhere except the subreddit itself.")
                }
            }

            if !filters.filteredUsers.isEmpty {
                Section {
                    ForEach(filters.filteredUsers, id: \.self) { name in
                        Label("u/\(name)", systemImage: "person")
                    }
                    .onDelete { offsets in
                        filters.removeUsers(atOffsets: offsets)
                    }
                } header: {
                    Text("Users")
                } footer: {
                    Text("Posts by these users are hidden everywhere except their profile.")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Filters")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FilteredContentView()
    }
}
