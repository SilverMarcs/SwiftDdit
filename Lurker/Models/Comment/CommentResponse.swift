//
//  CommentResponse.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 22/06/2025.
//

import Foundation

/// Response structure for Reddit's comments API
/// The API returns an array with [PostListing, CommentListing]
struct CommentResponse: Codable {
    let postListing: PostListing
    let commentListing: CommentListing
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        guard container.count == 2 else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected array with exactly 2 elements, got \(container.count ?? 0)"
                )
            )
        }
        
        // First element is the post listing
        postListing = try container.decode(PostListing.self)
        
        // Second element is the comment listing
        commentListing = try container.decode(CommentListing.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(postListing)
        try container.encode(commentListing)
    }
    
    /// Get the main post data if available
    var post: PostData? {
        return postListing.data.children.first?.data
    }
    
    /// Get all comment data
    var comments: [CommentData] {
        return commentListing.data.children.map { $0.data }
    }
    
    /// Get pagination info
    var after: String? {
        return commentListing.data.after
    }
}
