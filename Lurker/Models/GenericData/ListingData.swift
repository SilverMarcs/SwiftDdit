//
//  ListingResponse.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import Foundation

// Generic Listing structures for Reddit API responses
struct Listing<T: Codable>: Codable {
    let kind: String
    let data: ListingData<T>
}

struct ListingData<T: Codable>: Codable {
    let after: String?
    let before: String?
    let children: [ListingChild<T>]
}

struct ListingChild<T: Codable>: Codable {
    let kind: String
    let data: T
}

// Specific types for convenience
typealias PostListing = Listing<PostData>
typealias PostListingResponse = PostListing
typealias CommentListing = Listing<CommentData>
typealias SubredditListing = Listing<SubredditData>
typealias UserListing = Listing<UserData>
typealias MessageListing = Listing<Message>

