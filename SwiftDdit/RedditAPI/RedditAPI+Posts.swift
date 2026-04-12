//
//  APIPostFetcher.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

extension RedditAPI {
    static func fetchPosts(for feedType: PostFeedType, sort: SubListingSortOption = .best, after: String? = nil, limit: Int = 10) async -> ([Post], String?)? {
        guard let url = buildPostsURL(for: feedType, sort: sort, after: after, limit: limit) else { return nil }
        return await fetchPostsFromURL(url: url)
    }
    
    // MARK: - Private Helper Methods
    
    private static func buildPostsURL(for feedType: PostFeedType, sort: SubListingSortOption, after: String?, limit: Int) -> URL? {
        guard let endpoint = buildEndpoint(for: feedType, sort: sort) else { return nil }
        
        var components = URLComponents(string: "\(Self.baseURL)\(endpoint).json")
        components?.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "raw_json", value: "1"),
            URLQueryItem(name: "sr_detail", value: "1")
        ]
        
        if let after = after {
            components?.queryItems?.append(URLQueryItem(name: "after", value: after))
        }
        
        // Add time parameter for top sorting
        if let timeParam = sort.timeParameter {
            components?.queryItems?.append(URLQueryItem(name: "t", value: timeParam))
        }
        
        return components?.url
    }
    
    static private func buildEndpoint(for feedType: PostFeedType, sort: SubListingSortOption) -> String? {
        let sortPath = sort.apiPath.lowercased()
        
        switch feedType {
        case .home:
            return "/\(sortPath)"
            
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
    
    private static func fetchPostsFromURL(url: URL) async -> ([Post], String?)? {
        guard let listingResponse = await performAuthenticatedRequest(url: url, responseType: PostListingResponse.self) else {
            return nil
        }
        
        let posts = listingResponse.data.children.compactMap { child -> Post? in
            guard child.kind == "t3" else { return nil }
            return Post(from: child.data)
        }
        
        return (posts, listingResponse.data.after)
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
