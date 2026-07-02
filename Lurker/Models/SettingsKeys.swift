//
//  SettingsKeys.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 02/07/2026.
//

import Foundation

/// Canonical UserDefaults keys shared between `@AppStorage` views and the raw
/// `UserDefaults` reads in non-view types (e.g. `PostListDataSource`), so the
/// strings live in exactly one place.
enum SettingsKeys {
    static let persistFeed = "persistFeedSelection"
    static let lastFeed    = "lastFeedSelection"
    static let persistSort = "persistSortSelection"
    static let lastSort    = "lastSortSelection"
    /// Easter-egg gated: hide the feed switcher from the feed toolbar.
    static let hideFeedSwitcher = "hideFeedSwitcher"
}
