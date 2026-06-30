//
//  PostFeedType.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import Foundation

enum PostFeedType: Identifiable, Hashable {
    case home
    case popular
    case all
    case subreddit(Subreddit)
    case saved
    case user(String) // username

    /// The selectable front-page feeds shown in the Home tab's title menu.
    static let frontPageFeeds: [PostFeedType] = [.home, .popular, .all]

    var id: String {
        switch self {
        case .home:
            return "home"
        case .popular:
            return "popular"
        case .all:
            return "all"
        case .subreddit(let subreddit):
            return "subreddit_\(subreddit.id)"
        case .saved:
            return "saved"
        case .user(let username):
            return "user_\(username)"
        }
    }

    var displayName: String {
        switch self {
        case .home:
            return "Home"
        case .popular:
            return "Popular"
        case .all:
            return "All"
        case .subreddit(let subreddit):
            return subreddit.displayNamePrefixed
        case .saved:
            return "Saved"
        case .user(let username):
            return "u/\(username)"
        }
    }

    /// SF Symbol used in the front-page title menu.
    var icon: String {
        switch self {
        case .home:
            return "house"
        case .popular:
            return "flame"
        case .all:
            return "globe"
        case .subreddit:
            return "r.circle"
        case .saved:
            return "bookmark"
        case .user:
            return "person"
        }
    }

    var canSort: Bool {
        switch self {
        case .home, .popular, .all, .subreddit:
            return true
        case .saved, .user:
            return false
        }
    }

    /// `best` is only valid for the logged-in home feed; r/popular and r/all
    /// reject it, so they default to `hot`.
    var defaultSort: SubListingSortOption {
        switch self {
        case .popular, .all:
            return .hot
        case .home, .subreddit, .saved, .user:
            return .best
        }
    }

    /// Whether this feed type supports search functionality
    var supportsSearch: Bool {
        switch self {
        case .subreddit:
            return true
        case .home, .popular, .all, .saved, .user:
            return false
        }
    }

    /// Whether this feed shows subreddit-specific content
    var isSubredditSpecific: Bool {
        switch self {
        case .subreddit:
            return true
        case .home, .popular, .all, .saved, .user:
            return false
        }
    }

    /// Whether this feed shows user-specific content
    var isUserSpecific: Bool {
        switch self {
        case .saved, .user:
            return true
        case .home, .popular, .all, .subreddit:
            return false
        }
    }

    var subreddit: Subreddit? {
        switch self {
        case .subreddit(let subreddit):
            return subreddit
        case .home, .popular, .all, .saved, .user:
            return nil
        }
    }
}
