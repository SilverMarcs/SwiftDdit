//
//  CompactPostView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI
import CachedAsyncImage

struct CompactPostView: View {
    @Environment(\.appendToPath) var appendToPath
    let post: Post
    var isPreview: Bool = false
    
    var body: some View {
        Button {
            appendToPath(post)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 5) {
                        SubredditButton(subreddit: post.subreddit, type: .text)
                            .font(.subheadline)
                        
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Text(post.timeAgo)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    
                    
                    // Title
                    Text(post.title)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up")
                            Text(post.formattedUps)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                            Text(post.formattedNumComments)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if let url = post.mediaType.firstMediaURL, let mediaURL = URL(string: url) {
                    CachedAsyncImage(url: mediaURL, targetSize: CGSize(width: 500, height: 500))
                        .frame(width: 70, height: 70)
                        .cornerRadius(12)
                        .clipped()
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
