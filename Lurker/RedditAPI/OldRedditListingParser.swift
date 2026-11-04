//
//  OldRedditListingParser.swift
//  Lurker
//
//  Extracts the ordered post fullnames and the next-page cursor from an
//  old.reddit.com listing page.
//

import Foundation

/// Pure parsing, so it's `nonisolated` and can run off the main actor.
///
/// Scans the raw UTF-8 bytes for a few fixed markers instead of using `Regex`:
/// a listing page is a few hundred KB, and a regex over the whole page took
/// around 60 ms on a Mac (more on older iPhones), while this scan takes under 1 ms.
nonisolated enum OldRedditListingParser {
    struct Page: Equatable, Sendable {
        /// Whether the page contains a listing at all. False for pages such as
        /// the login page, so callers can tell them apart from an empty listing.
        let isListing: Bool
        /// Post fullnames (`t3_…`) in display order, excluding promoted posts.
        let fullnames: [String]
        /// Unique subreddit fullnames (`t5_…`) of those posts.
        let subredditFullnames: [String]
        /// The `after` cursor for the next page, or nil on the last page.
        let after: String?
    }

    /// Parse a listing page on a background thread.
    @concurrent
    static func parseInBackground(_ data: Data) async -> Page {
        parse(bytes: Array(data))
    }

    static func parse(html: String) -> Page {
        parse(bytes: Array(html.utf8))
    }

    private static let siteTableMarker = Array(#"id="siteTable""#.utf8)
    private static let fullnameMarker = Array(#"data-fullname="t3_"#.utf8)
    private static let subredditMarker = Array(#"data-subreddit-fullname=""#.utf8)
    private static let promotedMarker = Array(#"data-promoted="true""#.utf8)
    private static let thingMarker = Array("thing".utf8)
    private static let divMarker = Array("<div".utf8)
    private static let nextButtonMarker = Array(#"class="next-button""#.utf8)
    private static let hrefMarker = Array(#"href=""#.utf8)
    private static let afterMarker = Array("after=t3_".utf8)

    private static let quote = UInt8(ascii: "\"")
    private static let tagOpen = UInt8(ascii: "<")
    private static let tagClose = UInt8(ascii: ">")

    static func parse(bytes: [UInt8]) -> Page {
        let isListing = firstIndex(of: siteTableMarker, in: bytes[...]) != nil

        var fullnames: [String] = []
        var seen = Set<String>()
        var subredditFullnames: [String] = []
        var seenSubreddits = Set<String>()

        // Each post is an opening tag like:
        // <div class=" thing id-t3_abc … link " … data-fullname="t3_abc" … data-promoted="false" … >
        var searchStart = bytes.startIndex
        while let markerStart = firstIndex(of: fullnameMarker, in: bytes[searchStart...]) {
            let valueStart = markerStart + fullnameMarker.count - 3 // keep the "t3_" prefix
            guard let tagEnd = bytes[markerStart...].firstIndex(of: tagClose) else { break }
            searchStart = tagEnd

            guard let tagStart = bytes[..<markerStart].lastIndex(of: tagOpen) else { continue }
            let tag = bytes[tagStart..<tagEnd]
            guard tag.starts(with: divMarker),
                  firstIndex(of: thingMarker, in: tag) != nil,
                  firstIndex(of: promotedMarker, in: tag) == nil,
                  let name = attributeValue(in: bytes[valueStart..<tagEnd], prefix: "t3_"),
                  seen.insert(name).inserted else { continue }
            fullnames.append(name)

            if let subredditStart = firstIndex(of: subredditMarker, in: tag),
               let subreddit = attributeValue(in: bytes[(subredditStart + subredditMarker.count)..<tagEnd], prefix: "t5_"),
               seenSubreddits.insert(subreddit).inserted {
                subredditFullnames.append(subreddit)
            }
        }

        // <span class="next-button"><a href="https://old.reddit.com/r/all/?count=25&amp;after=t3_abc" …
        var after: String?
        if let nextButton = firstIndex(of: nextButtonMarker, in: bytes[...]),
           let hrefStart = firstIndex(of: hrefMarker, in: bytes[nextButton...]) {
            let valueStart = hrefStart + hrefMarker.count
            let valueEnd = bytes[valueStart...].firstIndex(of: quote) ?? bytes.endIndex
            if let afterStart = firstIndex(of: afterMarker, in: bytes[valueStart..<valueEnd]) {
                let cursorStart = afterStart + afterMarker.count - 3 // keep the "t3_" prefix
                let cursorEnd = bytes[cursorStart..<valueEnd].firstIndex { !isFullnameByte($0) } ?? valueEnd
                after = fullname(from: bytes[cursorStart..<cursorEnd], prefix: "t3_")
            }
        }

        return Page(isListing: isListing, fullnames: fullnames, subredditFullnames: subredditFullnames, after: after)
    }

    /// Reads an attribute value up to its closing quote, and returns it only if
    /// it's a well-formed fullname with the given prefix.
    private static func attributeValue(in bytes: ArraySlice<UInt8>, prefix: String) -> String? {
        guard let end = bytes.firstIndex(of: quote) else { return nil }
        return fullname(from: bytes[bytes.startIndex..<end], prefix: prefix)
    }

    private static func fullname(from bytes: ArraySlice<UInt8>, prefix: String) -> String? {
        guard bytes.count > prefix.utf8.count, bytes.starts(with: prefix.utf8),
              bytes.allSatisfy(isFullnameByte) else { return nil }
        return String(decoding: bytes, as: UTF8.self)
    }

    /// Fullnames are lowercase base-36 IDs with a `t3_`/`t5_` prefix.
    private static func isFullnameByte(_ byte: UInt8) -> Bool {
        (UInt8(ascii: "a")...UInt8(ascii: "z")).contains(byte)
            || (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte)
            || byte == UInt8(ascii: "_")
    }

    /// Index of the first occurrence of `needle` in `haystack`, if any.
    private static func firstIndex(of needle: [UInt8], in haystack: ArraySlice<UInt8>) -> Int? {
        guard let first = needle.first, haystack.count >= needle.count else { return nil }
        var index = haystack.startIndex
        let lastStart = haystack.endIndex - needle.count
        while index <= lastStart {
            guard let candidate = haystack[index...lastStart].firstIndex(of: first) else { return nil }
            if haystack[candidate..<(candidate + needle.count)].elementsEqual(needle) {
                return candidate
            }
            index = candidate + 1
        }
        return nil
    }
}
