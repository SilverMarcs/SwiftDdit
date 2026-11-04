//
//  RedditAPI+OldRedditFallback.swift
//  Lurker
//
//  Reddit now answers some `.json` listings (e.g. `/hot`, `/new`, `/rising`
//  and everything under `/r/all`) with a 403 "blocked by network security"
//  HTML page, even for logged-in sessions. The same listings still render on
//  old.reddit.com, and old.reddit.com's `/api/info` still returns full post
//  JSON. This fallback reads the ordered post IDs from the old.reddit listing
//  HTML and hydrates them through `/api/info.json`.
//
//  old.reddit.com requires a logged-in session; logged-out requests are
//  redirected to its login page, which the fallback treats as a failure.
//

import Foundation

extension RedditAPI {
    static let oldRedditBaseURL = "https://old.reddit.com"

    /// Result of trying a listing's `.json` endpoint.
    private enum JSONListingOutcome {
        case success([Post], String?)
        /// Reddit's anti-bot 403 (an HTML page, not a JSON error).
        case blocked
        /// Any other failure (offline, timeout, 429, 5xx, decode error, private
        /// subreddit). These must not trigger the fallback: it would only add
        /// load, and could hide a real bug.
        case failed
    }

    /// Listing kinds (e.g. `all/hot`, `subreddit/new`) whose `.json` was
    /// blocked and then served by the fallback this session. These skip the
    /// doomed `.json` attempt. Keyed by kind rather than full path, since
    /// Reddit blocks by listing type, so opening a new subreddit doesn't pay a
    /// failed round trip first. In-memory only, so each launch re-checks.
    private static var blockedListingKinds: Set<String> = []

    /// Subreddit details by fullname (`t5_…`), reused across pages so each
    /// subreddit is only looked up once. Only the fields `Subreddit(detail:)`
    /// uses are kept, and the cache is bounded.
    private static var subredditDetailCache: [String: SubredditDetail] = [:]
    private static let subredditDetailCacheLimit = 500

    /// Fetch a listing, going straight to old.reddit.com for listing kinds known
    /// to be blocked, and falling back to it when `.json` hits the anti-bot block.
    /// - Parameters:
    ///   - endpoint: Listing path such as `/r/all/hot` (no `.json` suffix).
    ///   - kind: Listing kind used to remember blocks, such as `all/hot`.
    ///   - jsonURL: The full `.json` URL for the listing.
    ///   - queryItems: Paging/sort query items (`limit`, `after`, `t`, …).
    static func fetchListing(endpoint: String, kind: String, jsonURL: URL, queryItems: [URLQueryItem]) async -> ([Post], String?)? {
        if blockedListingKinds.contains(kind) {
            if let result = await fetchPostsViaOldReddit(endpoint: endpoint, queryItems: queryItems) {
                return result
            }
            // The fallback failed; try .json again, and forget the kind only if
            // .json now works.
        }

        switch await fetchJSONListing(url: jsonURL) {
        case .success(let posts, let after):
            blockedListingKinds.remove(kind)
            return (posts, after)
        case .failed:
            return nil
        case .blocked:
            debugLog("falling back to old.reddit for \(endpoint)")
            guard let result = await fetchPostsViaOldReddit(endpoint: endpoint, queryItems: queryItems) else { return nil }
            blockedListingKinds.insert(kind)
            return result
        }
    }

    private static func fetchJSONListing(url: URL) async -> JSONListingOutcome {
        guard let request = await createAuthenticatedRequest(url: url) else { return .failed }
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { return .failed }
            guard httpResponse.statusCode == 200 else {
                debugLog("GET \(url.absoluteString) — status=\(httpResponse.statusCode)")
                // A 403 for a private or banned subreddit is JSON; only the
                // anti-bot block is an HTML page.
                let isHTML = httpResponse.mimeType == "text/html"
                return httpResponse.statusCode == 403 && isHTML ? .blocked : .failed
            }
            let listing = try JSONDecoder().decode(PostListingResponse.self, from: data)
            let posts = listing.data.children
                .filter { $0.kind == "t3" }
                .map { Post(from: $0.data) }
            return .success(posts, listing.data.after)
        } catch {
            debugLog("GET \(url.absoluteString) — error=\(error)")
            return .failed
        }
    }

    /// Fetch a listing through old.reddit.com when the `.json` endpoint is blocked.
    /// - Parameters:
    ///   - endpoint: Listing path such as `/r/all/hot` (no `.json` suffix).
    ///   - queryItems: Paging/sort query items (`limit`, `after`, `t`, …).
    /// - Returns: nil if the page couldn't be loaded or isn't a listing (for
    ///   example the login page, when there's no valid session).
    static func fetchPostsViaOldReddit(endpoint: String, queryItems: [URLQueryItem]) async -> ([Post], String?)? {
        let path = endpoint.hasSuffix("/") ? endpoint : "\(endpoint)/"
        var components = URLComponents(string: "\(oldRedditBaseURL)\(path)")
        components?.queryItems = queryItems
        guard let listingURL = components?.url,
              let request = await createAuthenticatedRequest(url: listingURL) else { return nil }

        let data: Data
        do {
            let response: URLResponse
            (data, response) = try await URLSession.shared.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            guard status == 200 else {
                debugLog("old.reddit fallback \(listingURL.absoluteString) — status=\(status)")
                return nil
            }
            // Logged-out requests are redirected to a login page that returns 200.
            if response.url?.path().hasPrefix("/login") == true {
                debugLog("old.reddit fallback \(listingURL.absoluteString) — redirected to login")
                return nil
            }
        } catch {
            debugLog("old.reddit fallback \(listingURL.absoluteString) — error=\(error)")
            return nil
        }

        let page = await OldRedditListingParser.parseInBackground(data)
        guard page.isListing else {
            debugLog("old.reddit fallback \(listingURL.absoluteString) — not a listing page")
            return nil
        }
        guard !page.fullnames.isEmpty else { return ([], nil) }

        // `/api/info` ignores `sr_detail=1`, so look up the subreddits too (to
        // keep icons and colors), skipping ones already cached, in parallel with the posts.
        let missingSubreddits = page.subredditFullnames.filter { subredditDetailCache[$0] == nil }
        async let subredditDetails = fetchSubredditDetails(fullnames: missingSubreddits)
        guard let postListing = await fetchInfo(fullnames: page.fullnames, responseType: PostListingResponse.self) else {
            return nil
        }
        cacheSubredditDetails(await subredditDetails)

        let postsByFullname = Dictionary(
            postListing.data.children
                .filter { $0.kind == "t3" }
                .map { ($0.data.name, $0.data) },
            uniquingKeysWith: { first, _ in first }
        )

        // `/api/info` doesn't guarantee order, so restore the listing's order.
        let posts = page.fullnames.compactMap { postsByFullname[$0] }.map { postData in
            Post(from: postData, subredditDetail: postData.subreddit_id.flatMap { subredditDetailCache[$0] })
        }
        return (posts, page.after)
    }

    private static func fetchSubredditDetails(fullnames: [String]) async -> [SubredditDetail] {
        await fetchInfo(fullnames: fullnames, responseType: Listing<SubredditDetail>.self)?.data.children.map(\.data) ?? []
    }

    private static func cacheSubredditDetails(_ details: [SubredditDetail]) {
        guard !details.isEmpty else { return }
        if subredditDetailCache.count + details.count > subredditDetailCacheLimit {
            subredditDetailCache.removeAll(keepingCapacity: true)
        }
        for detail in details {
            subredditDetailCache[detail.name] = trimmed(detail)
        }
    }

    /// Drop the large fields (such as the sidebar `description`) that
    /// `Subreddit(detail:)` doesn't use, so cached entries stay small.
    private static func trimmed(_ detail: SubredditDetail) -> SubredditDetail {
        SubredditDetail(
            name: detail.name,
            display_name: detail.display_name,
            display_name_prefixed: detail.display_name_prefixed,
            community_icon: detail.community_icon,
            icon_img: detail.icon_img,
            public_description: detail.public_description,
            subscribers: detail.subscribers,
            over_18: detail.over_18,
            user_is_subscriber: detail.user_is_subscriber,
            subreddit_type: detail.subreddit_type,
            created_utc: nil,
            title: nil,
            url: detail.url,
            description: nil,
            banner_img: nil,
            key_color: detail.key_color,
            primary_color: detail.primary_color,
            quarantine: detail.quarantine,
            user_is_moderator: nil,
            user_is_banned: nil,
            user_is_contributor: nil,
            user_is_muted: nil
        )
    }

    /// Look up things by fullname (`t3_…`, `t5_…`) via old.reddit.com's `/api/info.json`.
    private static func fetchInfo<T: Codable>(fullnames: [String], responseType: T.Type) async -> T? {
        guard !fullnames.isEmpty else { return nil }
        var components = URLComponents(string: "\(oldRedditBaseURL)/api/info.json")
        components?.queryItems = [
            URLQueryItem(name: "id", value: fullnames.joined(separator: ",")),
            URLQueryItem(name: "raw_json", value: "1")
        ]
        guard let url = components?.url else { return nil }
        return await performAuthenticatedRequest(url: url, responseType: responseType)
    }
}
