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

    /// The selectable front-page feeds shown in the Home tab's feed switcher.
    static let frontPageFeeds: [PostFeedType] = [.home, .popular, .all]

    /// Reconstruct a front-page feed from its persisted `id` string.
    static func frontPageFeed(id: String) -> PostFeedType? {
        frontPageFeeds.first { $0.id == id }
    }

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
            return "chart.line.uptrend.xyaxis"
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

    /// The switchable front-page feeds (Home/Popular/All). Feed and sort
    /// persistence are scoped to these.
    var isFrontPage: Bool {
        switch self {
        case .home, .popular, .all:
            return true
        case .subreddit, .saved, .user:
            return false
        }
    }

    /// r/popular and r/all reject the `best` sort; every other feed accepts it.
    var supportsBestSort: Bool {
        switch self {
        case .popular, .all:
            return false
        case .home, .subreddit, .saved, .user:
            return true
        }
    }

    /// The sort a fresh feed opens with. When sort persistence is enabled this
    /// restores the last front-page sort (falling back to `defaultSort` if it's
    /// missing or invalid for this feed, e.g. `best` on r/popular).
    func resolvedInitialSort() -> SubListingSortOption {
        guard isFrontPage,
              UserDefaults.standard.bool(forKey: SettingsKeys.persistSort),
              let id = UserDefaults.standard.string(forKey: SettingsKeys.lastSort),
              let saved = SubListingSortOption.from(id: id) else {
            return defaultSort
        }
        if case .best = saved, !supportsBestSort { return defaultSort }
        return saved
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
