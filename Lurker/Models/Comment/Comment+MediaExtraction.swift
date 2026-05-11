//
//  Comment+MediaExtraction.swift
//  SwiftDdit
//

import Foundation
import SwiftUI

struct CommentMedia: Hashable, Identifiable {
    enum Kind: Hashable { case gif, image }
    let kind: Kind
    let image: GalleryImage
    var id: String { "\(kind)-\(image.url)" }
}

extension Comment {
    // Reddit's embedded media markdown: ![gif](...) or ![img](...)
    private static let embedPattern: NSRegularExpression? = {
        try? NSRegularExpression(pattern: #"!\[(?:gif|img)\]\(([^)]+)\)"#)
    }()

    // Bare image URLs (autolinks). Negative lookbehind avoids matching URLs already
    // inside markdown link syntax like `[text](url)` or `![alt](url)`.
    private static let urlPattern: NSRegularExpression? = {
        try? NSRegularExpression(pattern: #"(?<!\]\()https?://[^\s<>()\[\]]+"#)
    }()

    private static let imageHosts = ["preview.redd.it", "i.redd.it", "i.imgur.com"]
    private static let imageExtensions = [".jpg", ".jpeg", ".png", ".webp"]
    private static let gifExtensions = [".gif", ".gifv"]

    /// Extract gif/image references from a comment body.
    static func extractEmbeddedMedia(from data: CommentData) -> [CommentMedia] {
        guard let body = data.body, !body.isEmpty else { return [] }

        let metadata = data.media_metadata ?? [:]
        var results: [CommentMedia] = []
        var seen: Set<String> = []

        func append(_ media: CommentMedia?) {
            guard let media = media, seen.insert(media.image.url).inserted else { return }
            results.append(media)
        }

        // Embedded media tokens
        if let regex = embedPattern {
            let range = NSRange(body.startIndex..., in: body)
            for match in regex.matches(in: body, range: range) {
                guard let tokenRange = Range(match.range(at: 1), in: body) else { continue }
                append(resolveEmbedToken(String(body[tokenRange]), metadata: metadata))
            }
        }

        // Bare image autolinks
        if let regex = urlPattern {
            let range = NSRange(body.startIndex..., in: body)
            for match in regex.matches(in: body, range: range) {
                guard let urlRange = Range(match.range, in: body) else { continue }
                append(resolveImageURL(String(body[urlRange])))
            }
        }

        return results
    }

    /// Strip embed tokens and bare image URLs from the body. Non-image links are left alone.
    static func stripMediaTokens(from body: String) -> String {
        var result = body

        // Strip every embed except emotes (which we render as-is text).
        if let regex = embedPattern {
            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, range: range)
            for match in matches.reversed() {
                guard let tokenRange = Range(match.range(at: 1), in: result),
                      let fullRange = Range(match.range, in: result) else { continue }
                let token = String(result[tokenRange])
                if token.hasPrefix("emote|") { continue }
                result.removeSubrange(fullRange)
            }
        }

        // Strip bare image URLs that we've inlined.
        if let regex = urlPattern {
            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, range: range)
            for match in matches.reversed() {
                guard let urlRange = Range(match.range, in: result) else { continue }
                let urlString = String(result[urlRange])
                if isImageURL(urlString) {
                    result.removeSubrange(urlRange)
                }
            }
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Resolvers

    private static func resolveEmbedToken(_ token: String, metadata: [String: MediaMetadataItem?]) -> CommentMedia? {
        // Skip subreddit emotes.
        if token.hasPrefix("emote|") { return nil }

        // Reddit-hosted media via media_metadata.
        if let item = metadata[token].flatMap({ $0 }),
           let size = item.s,
           let rawURL = size.u {
            let cleanURL = rawURL.replacingOccurrences(of: "&amp;", with: "&")
            let kind: CommentMedia.Kind = (item.m?.contains("gif") == true) ? .gif : .image
            return CommentMedia(
                kind: kind,
                image: GalleryImage(url: cleanURL, dimensions: CGSize(width: size.x, height: size.y))
            )
        }

        // Giphy fallback.
        if token.hasPrefix("giphy|") {
            let parts = token.split(separator: "|")
            if parts.count >= 2 {
                let id = String(parts[1])
                let url = "https://i.giphy.com/media/\(id)/giphy.gif"
                return CommentMedia(kind: .gif, image: GalleryImage(url: url, dimensions: nil))
            }
        }

        // Plain URL inside embed token, just in case.
        if token.hasPrefix("http") {
            return resolveImageURL(token)
        }

        return nil
    }

    private static func resolveImageURL(_ urlString: String) -> CommentMedia? {
        let clean = urlString.replacingOccurrences(of: "&amp;", with: "&")
        guard isImageURL(clean) else { return nil }
        let kind: CommentMedia.Kind = isGIFURL(clean) ? .gif : .image
        return CommentMedia(kind: kind, image: GalleryImage(url: clean, dimensions: nil))
    }

    // MARK: - URL classification

    private static func isImageURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        if let host = url.host?.lowercased(), imageHosts.contains(where: { host.contains($0) }) {
            return true
        }
        let path = url.path.lowercased()
        return imageExtensions.contains(where: path.hasSuffix) || gifExtensions.contains(where: path.hasSuffix)
    }

    private static func isGIFURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        let path = url.path.lowercased()
        return gifExtensions.contains(where: path.hasSuffix)
    }
}
