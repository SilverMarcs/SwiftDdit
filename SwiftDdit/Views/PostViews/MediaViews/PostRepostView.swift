//
//  PostRepostView.swift
//  SwiftDdit
//
//  Created by SwiftDdit Team on 18/06/2025.
//

import SwiftUI

struct PostRepostView: View {
    let originalPost: Post

    @Environment(NavigationPathManager.self) var navigationManager

    var body: some View {
        Button {
            navigationManager.path.append(originalPost)
        } label: {
            VStack(alignment: .leading) {
                // Repost header
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(.secondary)
                        .font(.caption)

                    Text(originalPost.subreddit.displayNamePrefixed)
                        .foregroundStyle(.secondary)
                        .font(.caption)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(originalPost.formattedUps)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Original post content preview
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(originalPost.title)
                        .font(.headline)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    // Show original post's media if it has any (but smaller)
                    if originalPost.mediaType.hasMedia && !isRepostOfRepost(originalPost.mediaType) {
                        PostMediaView(mediaType: originalPost.mediaType)
                            .frame(maxHeight: 250)
                            .clipped()
                            .cornerRadius(8)
                    }

                    // Selftext preview for text posts
                    if originalPost.isSelf && !originalPost.selftext.isEmpty {
                        Text(originalPost.selftext.prefix(100))
                            .font(.subheadline)
                            .lineLimit(2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(.background.secondary, in: .rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func isRepostOfRepost(_ mediaType: MediaType) -> Bool {
        if case .repost = mediaType {
            return true
        }
        return false
    }
}
