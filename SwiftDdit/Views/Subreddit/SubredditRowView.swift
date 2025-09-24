//
//  SubredditRowView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI
import SwiftMediaViewer

struct SubredditRowView: View {
    @Environment(\.appendToPath) var appendToPath
    let subreddit: Subreddit
    
    var body: some View {
        Button {
            appendToPath(PostFeedType.subreddit(subreddit))
        } label: {
            HStack {
                Label {
                    Text(subreddit.displayNamePrefixed)
                    if subreddit.subscriberCount > 0 {
                        Text("\(subreddit.formattedSubscriberCount) subscribers")
                    }
                } icon : {
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
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary.opacity(0.6))
                    .font(.system(size: 13.5, weight: .medium))
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
