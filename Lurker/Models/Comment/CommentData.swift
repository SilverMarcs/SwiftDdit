//
//  CommentData.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import Foundation

/// Raw comment data structure matching Reddit's API response
struct CommentData: Identifiable, Codable, Hashable {
    let id: String
    let author: String?
    let body: String?
    let body_html: String?
    let created_utc: Double?
    let score: Int?
    let ups: Int?
    let downs: Int?
    let likes: Bool?
    let saved: Bool?
    let archived: Bool?
    let depth: Int?
    let permalink: String?
    let parent_id: String?
    let link_id: String?
    let subreddit: String?
    let subreddit_id: String?
    let name: String?
    let author_fullname: String?
    let author_flair_text: String?
    let author_flair_background_color: String?
    let is_submitter: Bool?
    let send_replies: Bool?
    let collapsed: Bool?
    let count: Int?
    let children: [String]?
    let mod_reports: [String]?
    let num_reports: Int?
    let distinguished: String?
    let stickied: Bool?
    let locked: Bool?
    let can_gild: Bool?
    let gilded: Int?
    let total_awards_received: Int?
    let top_awarded_type: String?
    
    static func == (lhs: CommentData, rhs: CommentData) -> Bool {
        return lhs.id == rhs.id &&
               lhs.author == rhs.author &&
               lhs.created_utc == rhs.created_utc
    }
    
    // Nested replies - can be either empty string or actual listing
    let replies: CommentReplies?
    
    // Custom hash to handle optionals
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(author)
        hasher.combine(created_utc)
    }
}

/// Handle replies which can be empty string, nested listing, or null
enum CommentReplies: Codable {
    case empty(String)
    case listing(Listing<CommentData>)
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Check for null first
        if container.decodeNil() {
            self = .null
            return
        }
        
        // Try to decode as string
        if let stringValue = try? container.decode(String.self) {
            self = .empty(stringValue)
            return
        }
        
        // Try to decode as listing
        if let listingValue = try? container.decode(Listing<CommentData>.self) {
            self = .listing(listingValue)
            return
        }
        
        // If all else fails, treat as null (fallback for unexpected formats)
        self = .null
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .empty(let string):
            try container.encode(string)
        case .listing(let listing):
            try container.encode(listing)
        case .null:
            try container.encodeNil()
        }
    }
}
