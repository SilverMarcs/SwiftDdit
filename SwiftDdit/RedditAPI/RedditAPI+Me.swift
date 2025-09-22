//
//  APIMeFetcher.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

extension RedditAPI {
    static func fetchMe() async -> UserData? {
        guard let url = URL(string: "\(Self.redditApiURLBase)/api/v1/me") else { return nil }
        return await performAuthenticatedRequest(url: url, responseType: UserData.self)
    }
    
    static func fetchMe(with accessToken: String) async -> UserData? {
        guard let url = URL(string: "\(Self.redditApiURLBase)/api/v1/me") else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(createUserAgent(), forHTTPHeaderField: "User-Agent")
        
        return await performSimpleRequest(request, responseType: UserData.self)
    }
    
    static func fetchInbox(after: String = "", limit: Int = 25) async -> ([Message]?, String?)? {
        var components = URLComponents(string: "\(Self.redditApiURLBase)/message/inbox.json")
        components?.queryItems = [
            URLQueryItem(name: "mark", value: "true"),
            URLQueryItem(name: "count", value: "0"),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "show", value: "all"),
            URLQueryItem(name: "sr_detail", value: "1"),
            URLQueryItem(name: "raw_json", value: "1")
        ]
        
        if !after.isEmpty {
            components?.queryItems?.append(URLQueryItem(name: "after", value: after))
        }
        
        guard let url = components?.url,
              let listing = await performAuthenticatedRequest(url: url, responseType: MessageListing.self) else { return nil }
        
        return (listing.data.children.map { $0.data }, listing.data.after)
    }
    
    static func fetchUserSubreddits() async -> [Subreddit]? {
        var allSubreddits: [Subreddit] = []
        var after: String? = nil
        
        repeat {
            var urlString = "\(Self.redditApiURLBase)/subreddits/mine/subscriber.json?limit=100"
            if let afterToken = after {
                urlString += "&after=\(afterToken)"
            }
            
            guard let url = URL(string: urlString),
                  let response = await performAuthenticatedRequest(url: url, responseType: Listing<SubredditData>.self) else {
                return nil
            }
            
            let newSubs = response.data.children.compactMap { Subreddit(data: $0.data) }
            allSubreddits.append(contentsOf: newSubs)
            
            after = response.data.after
        } while after != nil
        
        return allSubreddits
    }
}
