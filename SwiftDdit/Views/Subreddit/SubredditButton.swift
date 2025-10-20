//
//  SubredditButton.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI
import SwiftMediaViewer

struct SubredditButton: View {
    let subreddit: Subreddit
    let type: SubRedditButtonType
    
    var body: some View {
        NavigationLink(value: PostFeedType.subreddit(subreddit)) {
            switch type {
            case .text:
                Text(subreddit.displayNamePrefixed)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundStyle(subreddit.color ?? .blue)
            case .icon(let iconURL):
                if let url = URL(string: iconURL) {
                    CachedAsyncImage(url: url, targetSize: 50)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "r.circle")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .font(.title)
                        .foregroundStyle(subreddit.color ?? .blue)
                }
            }
        }
    }
}

enum SubRedditButtonType {
    case icon(iconUrl: String)
    case text
}
