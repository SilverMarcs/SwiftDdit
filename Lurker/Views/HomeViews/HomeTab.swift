//
//  HomeTab.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 18/06/25.
//

import SwiftUI

struct HomeTab: View {
    @Bindable var navigationManager = NavigationPathManager()
    @State private var feedType: PostFeedType = .home

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            PostsList(feedType: feedType)
                .id(feedType)
                .toolbarTitleMenu {
                    ForEach(PostFeedType.frontPageFeeds) { feed in
                        Button {
                            feedType = feed
                        } label: {
                            Label(feed.displayName, systemImage: feed.icon)
                        }
                    }
                }
                .navigationDestinations()
        }
        .environment(navigationManager)
        .handleURLs(path: $navigationManager.path)
    }
}

#Preview {
    HomeTab()
}
