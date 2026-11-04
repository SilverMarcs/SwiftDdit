//
//  APIPostFetcher.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

extension RedditAPI {
    static func fetchPosts(for feedType: PostFeedType, sort: SubListingSortOption = .best, after: String? = nil, limit: Int = 10) async -> ([Post], String?)? {
        guard let endpoint = buildEndpoint(for: feedType, sort: sort) else { return nil }
        let queryItems = buildQueryItems(sort: sort, after: after, limit: limit)

        var components = URLComponents(string: "\(Self.baseURL)\(endpoint).json")
        components?.queryItems = queryItems
        guard let url = components?.url else { return nil }

        // Reddit blocks some .json listings (hot/new/rising, r/all) even when
        // logged in; fetchListing falls back to old.reddit.com for those.
        let kind = "\(listingScope(for: feedType))/\(sort.apiPath.lowercased())"
        return await fetchListing(endpoint: endpoint, kind: kind, jsonURL: url, queryItems: queryItems)
    }

    // MARK: - Private Helper Methods

    private static func buildQueryItems(sort: SubListingSortOption, after: String?, limit: Int) -> [URLQueryItem] {
        var queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "raw_json", value: "1"),
            URLQueryItem(name: "sr_detail", value: "1")
        ]

        if let after = after {
            queryItems.append(URLQueryItem(name: "after", value: after))
        }

        // Add time parameter for top sorting
        if let timeParam = sort.timeParameter {
            queryItems.append(URLQueryItem(name: "t", value: timeParam))
        }

        return queryItems
    }
    
    static private func buildEndpoint(for feedType: PostFeedType, sort: SubListingSortOption) -> String? {
        let sortPath = sort.apiPath.lowercased()
        
        switch feedType {
        case .home:
            return "/\(sortPath)"

        case .popular:
            return "/r/popular/\(sortPath)"

        case .all:
            return "/r/all/\(sortPath)"

        case .subreddit(let subreddit):
            let subredditPath = "r/\(subreddit.displayName)"
            return "/\(subredditPath)/\(sortPath)"
            
        case .saved:
            guard let username = CredentialsManager.shared.credential?.userName else {
                AppLogger.error("No username available for saved posts")
                return nil
            }
            return "/user/\(username)/saved"
            
        case .user(let username):
            return "/user/\(username)/submitted"
        }
    }
    
    /// The kind of listing, without user-specific parts (subreddit or user
    /// names), so a block on one subreddit's listing applies to all of them.
    private static func listingScope(for feedType: PostFeedType) -> String {
        switch feedType {
        case .home: "home"
        case .popular: "popular"
        case .all: "all"
        case .subreddit: "subreddit"
        case .saved: "saved"
        case .user: "user"
        }
    }

    // MARK: - Post Actions
    
    @discardableResult
    static func vote(_ action: VoteAction, id: String) async -> Bool {
        guard let url = URL(string: "\(Self.baseURL)/api/vote") else { return false }
        let parameters = "dir=\(action.rawValue)&id=\(id)&api_type=json&raw_json=1"
        return await performPostRequest(url: url, parameters: parameters)
    }
    
    static func save(_ save: Bool, id: String) async -> Bool {
        let endpoint = save ? "save" : "unsave"
        guard let url = URL(string: "\(Self.baseURL)/api/\(endpoint)") else { return false }
        return await performPostRequest(url: url, parameters: "id=\(id)")
    }
}

// MARK: - Vote Action Enum

extension RedditAPI {
    enum VoteAction: String, Codable {
        case up = "1"
        case none = "0"
        case down = "-1"
        
        func boolVersion() -> Bool? {
            switch self {
            case .up:
                return true
            case .none:
                return nil
            case .down:
                return false
            }
        }
    }
}
