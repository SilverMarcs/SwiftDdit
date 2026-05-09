//
//  PostFeedType.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import Foundation

enum PostFeedType: Identifiable, Hashable {
    case home
    case subreddit(Subreddit)
    case saved
    case user(String) // username
    
    var id: String {
        switch self {
        case .home:
            return "home"
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
        case .subreddit(let subreddit):
            return subreddit.displayNamePrefixed
        case .saved:
            return "Saved"
        case .user(let username):
            return "u/\(username)"
        }
    }
    
    var canSort: Bool {
        switch self {
        case .home, .subreddit:
            return true
        case .saved, .user:
            return false
        }
    }
    
    /// Whether this feed type supports search functionality
    var supportsSearch: Bool {
        switch self {
        case .subreddit:
            return true
        case .home, .saved, .user:
            return false
        }
    }
    
    /// Whether this feed shows subreddit-specific content
    var isSubredditSpecific: Bool {
        switch self {
        case .subreddit:
            return true
        case .home, .saved, .user:
            return false
        }
    }
    
    /// Whether this feed shows user-specific content
    var isUserSpecific: Bool {
        switch self {
        case .saved, .user:
            return true
        case .home, .subreddit:
            return false
        }
    }
    
    var subreddit: Subreddit? {
        switch self {
        case .subreddit(let subreddit):
            return subreddit
        case .home, .saved, .user:
            return nil
        }
    }
}
