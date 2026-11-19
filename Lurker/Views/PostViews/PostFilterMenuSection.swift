//
//  PostFilterMenuSection.swift
//  SwiftDdit
//
//  Created by Kgirthofer on 03/11/2026.
//

import SwiftUI

/// Context-menu actions that hide (or unhide) a post's subreddit or author
/// from the user's feeds. App-only: nothing is sent to Reddit.
struct PostFilterMenuSection: View {
    let post: Post

    @State private var filters = FilterManager.shared

    private var subredditName: String { post.subreddit.displayName }
    private var canFilterAuthor: Bool { !post.author.isEmpty && post.author != "[deleted]" }

    var body: some View {
        Section {
            if !subredditName.isEmpty {
                let isFiltered = filters.isSubredditFiltered(subredditName)
                Button(
                    isFiltered ? "Unfilter r/\(subredditName)" : "Filter r/\(subredditName)",
                    systemImage: isFiltered ? "eye" : "eye.slash"
                ) {
                    withAnimation {
                        filters.toggleSubreddit(subredditName)
                    }
                }
            }

            if canFilterAuthor {
                let isFiltered = filters.isUserFiltered(post.author)
                Button(
                    isFiltered ? "Unfilter u/\(post.author)" : "Filter u/\(post.author)",
                    systemImage: isFiltered ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.xmark"
                ) {
                    withAnimation {
                        filters.toggleUser(post.author)
                    }
                }
            }
        }
    }
}
