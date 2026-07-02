//
//  FeedTypeMenuButton.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 02/07/2026.
//

import SwiftUI

struct FeedTypeMenuButton: View {
    @Binding var selection: PostFeedType

    var body: some View {
        Menu {
            ForEach(PostFeedType.frontPageFeeds) { feed in
                Button {
                    selection = feed
                } label: {
                    Label(feed.displayName, systemImage: feed.icon)
                }
            }
        } label: {
            Label(selection.displayName, systemImage: selection.icon)
                .labelStyle(.iconOnly)
        }
        .menuIndicator(.hidden)
        .tint(.accent)
    }
}
