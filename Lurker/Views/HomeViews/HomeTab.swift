//
//  HomeTab.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 18/06/25.
//

import SwiftUI

struct HomeTab: View {
    @Bindable var navigationManager = NavigationPathManager()
    @AppStorage(SettingsKeys.persistFeed) private var persistFeed = false
    @AppStorage(SettingsKeys.lastFeed) private var lastFeed = "home"
    @State private var feedType: PostFeedType

    init() {
        let persist = UserDefaults.standard.bool(forKey: SettingsKeys.persistFeed)
        let id = UserDefaults.standard.string(forKey: SettingsKeys.lastFeed) ?? "home"
        _feedType = State(initialValue: persist ? (PostFeedType.frontPageFeed(id: id) ?? .home) : .home)
    }

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            PostsList(feedType: feedType, feedTypeSelection: $feedType)
                .id(feedType)
                .navigationDestinations()
        }
        .environment(navigationManager)
        .handleURLs(path: $navigationManager.path)
        .onChange(of: feedType) {
            if persistFeed { lastFeed = feedType.id }
        }
    }
}

#Preview {
    HomeTab()
}
