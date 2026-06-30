//
//  FavoritesManager.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 30/06/2026.
//

import Foundation
import SwiftUI

/// Persists the user's favorited subreddits (by lowercased display name) so they
/// can be surfaced at the top of the subreddit list. Favorites are device-local.
@MainActor
@Observable
final class FavoritesManager {
    @ObservationIgnored static let shared = FavoritesManager()

    @ObservationIgnored private let defaultsKey = "favorite_subreddits"

    /// Lowercased subreddit display names, in the order they were favorited.
    private(set) var favoriteNames: [String]

    private init() {
        favoriteNames = UserDefaults.standard.stringArray(forKey: defaultsKey) ?? []
    }

    func isFavorite(_ subreddit: Subreddit) -> Bool {
        favoriteNames.contains(key(for: subreddit))
    }

    func toggle(_ subreddit: Subreddit) {
        let name = key(for: subreddit)
        if let index = favoriteNames.firstIndex(of: name) {
            favoriteNames.remove(at: index)
        } else {
            favoriteNames.append(name)
        }
        UserDefaults.standard.set(favoriteNames, forKey: defaultsKey)
    }

    private func key(for subreddit: Subreddit) -> String {
        subreddit.displayName.lowercased()
    }
}
