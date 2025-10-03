//
//  URLHandlingModifier.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 20/06/2025.
//

import SwiftUI
import SwiftMediaViewer

struct URLHandlingModifier: ViewModifier {
    let path: Binding<NavigationPath>
    let smvPresenter: SMVImagePresenter?

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                let lower = url.absoluteString.lowercased()

                // Let GIFs open with system
                if lower.contains(".gif") {
                    return .systemAction(prefersInApp: true)
                }
                
                if let smvPresenter {
                    if let galleryImage = detectRedditImage(from: url) {
                        smvPresenter.present(url: galleryImage.url, targetSize: 1200)
                        return .handled
                    }
                }

                if let navPayload = parseRedditURL(url) {
                    path.wrappedValue.append(navPayload)
                    return .handled
                }

                return .systemAction(prefersInApp: true)
            })
    }

    private func parseRedditURL(_ url: URL) -> (any Hashable)? {
        guard let host = url.host, host.contains("reddit.com") else { return nil }
        let comps = url.pathComponents.filter { $0 != "/" }

        if comps.count >= 5, comps[0] == "r", comps[2] == "comments" {
            let subreddit = comps[1]
            let postId = comps[3]
            if let cIdx = comps.firstIndex(of: "comment"), cIdx + 1 < comps.count {
                let commentId = comps[cIdx + 1]
                return PostNavigation(postId: postId, subreddit: subreddit, commentId: commentId)
            } else {
                return PostNavigation(postId: postId, subreddit: subreddit, commentId: nil)
            }
        }

        if comps.count >= 2, comps[0] == "r" {
            let subreddit = comps[1]
            let sub = Subreddit(displayName: subreddit)
            return PostFeedType.subreddit(sub)
        }
        return nil
    }

    private func detectRedditImage(from url: URL) -> GalleryImage? {
        let lower = url.absoluteString.lowercased()
        let hosts = ["preview.redd.it", "i.redd.it", "i.imgur.com"]
        let hostMatch = hosts.contains { url.host?.contains($0) == true }
        let extMatch = [".jpg", ".jpeg", ".png", ".webp"].contains { lower.hasSuffix($0) }
        guard hostMatch || extMatch else { return nil }
        return GalleryImage(url: url.absoluteString, dimensions: nil)
    }
}

extension View {
    func handleURLs(path: Binding<NavigationPath>, smvPresenter: SMVImagePresenter) -> some View {
        modifier(URLHandlingModifier(path: path, smvPresenter: smvPresenter))
    }
}
