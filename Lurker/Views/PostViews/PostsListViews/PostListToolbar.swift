//
//  PostListToolbar.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import SwiftUI

struct PostListToolbar: ToolbarContent {
    let feedType: PostFeedType
    @Binding var selectedSort: SubListingSortOption
    /// Present only for the front-page context; enables the feed switcher.
    var feedTypeSelection: Binding<PostFeedType>? = nil

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            if feedType.canSort {
                SortMenuButton(selectedSort: $selectedSort)
            }
            if let feedTypeSelection {
                FeedTypeMenuButton(selection: feedTypeSelection)
            }
        }

        if let subreddit = feedType.subreddit  {
            SubredditInfoButton(subreddit: subreddit)
        }

        if case .user(let username) = feedType {
            UserInfoButton(username: username)
        }
    }
}
