//
//  APISearcher.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import Foundation

extension RedditAPI {
    
    // MARK: - Generic Search Method
    
    private static func performSearch<T: Codable>(
        query: String,
        endpoint: String,
        queryItems: [URLQueryItem],
        responseType: T.Type
    ) async -> T? {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }

        var components = URLComponents(string: "\(Self.baseURL)/\(endpoint).json")
        components?.queryItems = queryItems
        
        guard let url = components?.url else { return nil }
        return await performAuthenticatedRequest(url: url, responseType: responseType)
    }
    
    // MARK: - Subreddit Search
    
    static func searchSubreddits(_ query: String, limit: Int = 30) async -> [Subreddit]? {
        let queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "sort", value: "relevance"),
            URLQueryItem(name: "raw_json", value: "1")
        ]
        
        guard let listingResponse: SubredditListing = await performSearch(
            query: query,
            endpoint: "subreddits/search",
            queryItems: queryItems,
            responseType: SubredditListing.self
        ) else { return query.isEmpty ? [] : nil }
        
        return listingResponse.data.children.compactMap { child -> Subreddit? in
            guard child.kind == "t5" else { return nil }
            return Subreddit(data: child.data)
        }
    }
    
    // MARK: - Post Search
    
    static func searchPosts(_ query: String, subreddit: String? = nil, limit: Int = 30) async -> [Post]? {
        let endpoint = subreddit != nil ? "r/\(subreddit!)/search" : "search"
        
        var queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "sort", value: "relevance"),
            URLQueryItem(name: "type", value: "link"),
            URLQueryItem(name: "raw_json", value: "1"),
            URLQueryItem(name: "sr_detail", value: "1")
        ]
        
        if subreddit != nil {
            queryItems.append(URLQueryItem(name: "restrict_sr", value: "true"))
        }
        
        guard let listingResponse: PostListing = await performSearch(
            query: query,
            endpoint: endpoint,
            queryItems: queryItems,
            responseType: PostListing.self
        ) else { return query.isEmpty ? [] : nil }
        
        return listingResponse.data.children.compactMap { child -> Post? in
            guard child.kind == "t3" else { return nil }
            return Post(from: child.data)
        }
    }
}
