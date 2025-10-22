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

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            if feedType.canSort,
               let subreddit = feedType.subreddit,
               !subreddit.displayName.hasPrefix("u_") {
                SortMenuButton(selectedSort: $selectedSort)
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
