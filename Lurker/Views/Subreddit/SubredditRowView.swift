//
//  SubredditRowView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI
import SwiftMediaViewer

struct SubredditRowView: View {
    let subreddit: Subreddit
    var showsFavoriteButton = false

    @Environment(NavigationPathManager.self) var navigationManager
    @State private var favorites = FavoritesManager.shared

    var body: some View {
        HStack(spacing: 12) {
            Button {
                navigationManager.path.append(PostFeedType.subreddit(subreddit))
            } label: {
                Label {
                    Text(subreddit.displayNamePrefixed)
                    if subreddit.subscriberCount > 0 {
                        Text("\(subreddit.formattedSubscriberCount) subscribers")
                    }
                } icon: {
                    if let iconURL = subreddit.iconURL, let url = URL(string: iconURL) {
                        CachedAsyncImage(url: url, targetSize: 50)
                            .foregroundStyle(subreddit.color ?? .secondary)
                            .clipShape(Circle())
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "r.circle")
                            .foregroundStyle(subreddit.color ?? .secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            if showsFavoriteButton {
                Button {
                    withAnimation(.smooth) { favorites.toggle(subreddit) }
                } label: {
                    Image(systemName: favorites.isFavorite(subreddit) ? "star.fill" : "star")
                        .foregroundStyle(favorites.isFavorite(subreddit) ? .yellow : .secondary)
                        .contentShape(.rect)
                }
                .buttonStyle(.borderless)
            }
        }
    }
}
