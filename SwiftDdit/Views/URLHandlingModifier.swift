//
//  URLHandlingModifier.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 20/06/2025.
//

import SwiftUI

struct URLHandlingModifier: ViewModifier {
    let path: Binding<NavigationPath>
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                // Check if URL contains "gif" - handle with system action
                if url.absoluteString.lowercased().contains("gif") {
                    return .systemAction(prefersInApp: true)
                }
                
                // TODO: fix this
//                if let galleryImage = detectRedditImage(from: url) {
//                    path.wrappedValue.append(ImageModalData(image: galleryImage))
//                    return .handled
//                }

                if let navPayload = parseRedditURL(url) {
                    path.wrappedValue.append(navPayload)
                    return .handled
                }

                return .systemAction(prefersInApp: true)
            })
    }
    
    /// Parses Reddit URLs for posts, comments, and subreddits
    private func parseRedditURL(_ url: URL) -> (any Hashable)? {
        guard let host = url.host, host.contains("reddit.com") else { return nil }
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        // Example: /r/MacOS/comments/1b5hetd/comment/mrdnu8n/
        // Example: /r/MacOS/comments/1b5hetd/can_i_just_turn_off_spotlight_indexing/
        // Example: /r/MacOS/

        if pathComponents.count >= 5, pathComponents[0] == "r", pathComponents[2] == "comments" {
            let subreddit = pathComponents[1]
            let postId = pathComponents[3]
            // Comment link
            if let commentIdx = pathComponents.firstIndex(of: "comment"), commentIdx + 1 < pathComponents.count {
                let commentId = pathComponents[commentIdx + 1]
                return PostNavigation(postId: postId, subreddit: subreddit, commentId: commentId)
            } else {
                // Post link
                return PostNavigation(postId: postId, subreddit: subreddit, commentId: nil)
            }
        }

        // Subreddit link: /r/MacOS/
        if pathComponents.count >= 2, pathComponents[0] == "r" {
            let subreddit = pathComponents[1]
            let sub = Subreddit(displayName: subreddit)
            return PostFeedType.subreddit(sub)
        }

        return nil
    }
    
    
    /// Detects if URL is a Reddit image and extracts dimensions if available
    private func detectRedditImage(from url: URL) -> GalleryImage? {
        let urlString = url.absoluteString
        
        // Check if URL matches Reddit image patterns
        let redditImagePatterns = [
            "preview.redd.it",
            "i.redd.it",
            "i.imgur.com"
        ]
        
        let isRedditImage = redditImagePatterns.contains { pattern in
            urlString.contains(pattern)
        }
        
        guard isRedditImage else { return nil }
        
        return GalleryImage(url: urlString, dimensions: nil)
    }
}

extension View {
    /// Applies Reddit-aware URL handling to this view
    func handleURLs(path: Binding<NavigationPath>) -> some View {
        modifier(URLHandlingModifier(path: path))
    }
}
