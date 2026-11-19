//
//  FilterManager.swift
//  SwiftDdit
//
//  Created by Kgirthofer on 03/11/2026.
//

import Foundation
import SwiftUI

/// Persists the subreddits and users the user has chosen to hide from their
/// feeds. Filters are app-only and device-local: nothing is sent to Reddit.
///
/// Names are kept with the casing they were filtered with (for display) and
/// compared case-insensitively.
@MainActor
@Observable
final class FilterManager {
    @ObservationIgnored static let shared = FilterManager()

    /// Filtered subreddit display names (without the `r/` prefix), in the
    /// order they were filtered.
    private(set) var filteredSubreddits: [String]

    /// Filtered usernames (without the `u/` prefix), in the order they were
    /// filtered.
    private(set) var filteredUsers: [String]

    /// Lowercased lookup sets mirroring the arrays above.
    private var subredditKeys: Set<String>
    private var userKeys: Set<String>

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let subreddits = defaults.stringArray(forKey: SettingsKeys.filteredSubreddits) ?? []
        let users = defaults.stringArray(forKey: SettingsKeys.filteredUsers) ?? []
        filteredSubreddits = subreddits
        filteredUsers = users
        subredditKeys = Set(subreddits.map(Self.key))
        userKeys = Set(users.map(Self.key))
    }

    // MARK: - Queries

    func isSubredditFiltered(_ name: String) -> Bool {
        subredditKeys.contains(Self.key(name))
    }

    func isUserFiltered(_ name: String) -> Bool {
        userKeys.contains(Self.key(name))
    }

    /// Whether `post` should be hidden when shown in `feedType`.
    func shouldHide(_ post: Post, in feedType: PostFeedType) -> Bool {
        Self.shouldHide(
            subreddit: post.subreddit.displayName,
            author: post.author,
            in: feedType,
            filteredSubreddits: subredditKeys,
            filteredUsers: userKeys
        )
    }

    /// Pure filtering rule. A filtered subreddit is hidden everywhere except its
    /// own feed, and a filtered user is hidden everywhere except their own
    /// profile. `filteredSubreddits` and `filteredUsers` must be lowercased.
    static func shouldHide(
        subreddit: String,
        author: String,
        in feedType: PostFeedType,
        filteredSubreddits: Set<String>,
        filteredUsers: Set<String>
    ) -> Bool {
        let subredditKey = key(subreddit)
        let authorKey = key(author)

        if filteredSubreddits.contains(subredditKey) {
            let isOwnFeed = feedType.subreddit.map { key($0.displayName) == subredditKey } ?? false
            if !isOwnFeed { return true }
        }

        if filteredUsers.contains(authorKey) {
            var isOwnProfile = false
            if case .user(let username) = feedType {
                isOwnProfile = key(username) == authorKey
            }
            if !isOwnProfile { return true }
        }

        return false
    }

    // MARK: - Subreddits

    func toggleSubreddit(_ name: String) {
        if isSubredditFiltered(name) {
            unfilterSubreddit(name)
        } else {
            filterSubreddit(name)
        }
    }

    func filterSubreddit(_ name: String) {
        let trimmed = Self.trimmed(name, prefix: "r/")
        guard !trimmed.isEmpty, !isSubredditFiltered(trimmed) else { return }
        filteredSubreddits.append(trimmed)
        subredditKeys.insert(Self.key(trimmed))
        saveSubreddits()
    }

    func unfilterSubreddit(_ name: String) {
        let key = Self.key(name)
        filteredSubreddits.removeAll { Self.key($0) == key }
        subredditKeys.remove(key)
        saveSubreddits()
    }

    func removeSubreddits(atOffsets offsets: IndexSet) {
        let names = offsets.map { filteredSubreddits[$0] }
        for name in names {
            unfilterSubreddit(name)
        }
    }

    // MARK: - Users

    func toggleUser(_ name: String) {
        if isUserFiltered(name) {
            unfilterUser(name)
        } else {
            filterUser(name)
        }
    }

    func filterUser(_ name: String) {
        let trimmed = Self.trimmed(name, prefix: "u/")
        guard !trimmed.isEmpty, !isUserFiltered(trimmed) else { return }
        filteredUsers.append(trimmed)
        userKeys.insert(Self.key(trimmed))
        saveUsers()
    }

    func unfilterUser(_ name: String) {
        let key = Self.key(name)
        filteredUsers.removeAll { Self.key($0) == key }
        userKeys.remove(key)
        saveUsers()
    }

    func removeUsers(atOffsets offsets: IndexSet) {
        let names = offsets.map { filteredUsers[$0] }
        for name in names {
            unfilterUser(name)
        }
    }

    // MARK: - Private

    private func saveSubreddits() {
        defaults.set(filteredSubreddits, forKey: SettingsKeys.filteredSubreddits)
    }

    private func saveUsers() {
        defaults.set(filteredUsers, forKey: SettingsKeys.filteredUsers)
    }

    private static func key(_ name: String) -> String {
        name.lowercased()
    }

    private static func trimmed(_ name: String, prefix: String) -> String {
        var result = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if result.lowercased().hasPrefix(prefix) {
            result = String(result.dropFirst(prefix.count))
        }
        return result
    }
}
