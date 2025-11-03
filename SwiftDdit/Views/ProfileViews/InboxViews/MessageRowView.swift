//
//  MessageRowView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct MessageRowView: View {
    let message: Message

    @Environment(NavigationPathManager.self) var navigationManager

    var body: some View {
        Button {
            if let nav = message.postNavigation {
                // Navigate to the related post/comment
                navigationManager.path.append(nav)
            } else {
                // Fallback: show message details when no post navigation is available
                navigationManager.path.append(message)
            }
        } label: {
            HStack(alignment: .top) {
                Image(systemName: message.iconConfig.symbol)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(message.iconConfig.color)

                VStack(alignment: .leading, spacing: 8) {
                    // Message content
                    if let body = message.body, !body.isEmpty {
                        Text(body)
                            .lineLimit(2)
                            .font(.subheadline)
                    }

                    // Link title if it's a comment reply
                    if let linkTitle = message.linkTitle, !linkTitle.isEmpty {
                        Text("Re: \(linkTitle)")
                            .font(.caption)
                            .lineLimit(2)
                            .foregroundStyle(.secondary)
                            .italic()
                    }

                    HStack {
                        if let subreddit = message.subredditNamePrefixed {
                            Text(subreddit)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if let author = message.author {
                            Text("u/\(author)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text("•")
//                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let timeAgo = message.timeAgo {
                            Text(timeAgo)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
