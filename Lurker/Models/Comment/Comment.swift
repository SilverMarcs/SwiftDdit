//
//  Comment.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

/// Flattened comment for list display
struct Comment: Identifiable, Hashable, Votable {
    let id: String
    let author: String
    let body: String
    let created: Double
    let score: Int
    let ups: Int
    let depth: Int
    let parentID: String?
    let isSubmitter: Bool
    let authorFlairText: String?
    let authorFlairBackgroundColor: String?
    let distinguished: String?
    let stickied: Bool
    let likes: Bool?
    
    // Flattened display properties
    let hasChildren: Bool
    let childCount: Int
    let childIds: [String]
    
    // Pre-computed formatted values
    let formattedUps: String
    let timeAgo: String
    
    // Pre-computed colors
    let flairBackgroundColor: Color
    let depthColor: Color
    
    private static let depthColors: [Color] = [
        .blue, .green, .orange, .purple, .red, .pink, .teal, .indigo
    ]
    
    var fullname: String {
        return "t1_\(id)"
    }
    
    /// Direct initializer from CommentData for performance optimization
    init(from commentData: CommentData, hasChildren: Bool = false, childCount: Int = 0, childIds: [String] = []) {
        self.id = commentData.id
        self.author = commentData.author ?? "[deleted]"
        self.body = commentData.body ?? "[deleted]"
        self.created = commentData.created_utc ?? 0
        self.score = commentData.score ?? commentData.ups ?? 0
        self.ups = commentData.ups ?? 0
        self.depth = commentData.depth ?? 0
        self.parentID = commentData.parent_id
        self.isSubmitter = commentData.is_submitter ?? false
        self.authorFlairText = commentData.author_flair_text
        self.authorFlairBackgroundColor = commentData.author_flair_background_color
        self.distinguished = commentData.distinguished
        self.stickied = commentData.stickied ?? false
        self.likes = commentData.likes
        self.hasChildren = hasChildren
        self.childCount = childCount
        self.childIds = childIds
        
        // Pre-compute formatted values
        let upsValue = commentData.ups ?? 0
        self.formattedUps = upsValue.formatted
        self.timeAgo = (commentData.created_utc ?? 0).timeAgo
        
        // Pre-compute colors safely
        if let bgColor = commentData.author_flair_background_color, !bgColor.isEmpty {
            self.flairBackgroundColor = Color(hex: bgColor)
        } else {
            self.flairBackgroundColor = .clear
        }
        
        let safeDepth = max(0, (commentData.depth ?? 0) - 1)
        self.depthColor = Self.depthColors[safeDepth % Self.depthColors.count]
    }
    
    init(id: String,
         author: String,
         body: String,
         depth: Int,
         parentID: String,
         created: Double = Date().timeIntervalSince1970) {
        self.id = id
        self.author = author
        self.body = body
        self.created = created
        self.depth = depth
        self.parentID = parentID
        
        // Common values for placeholder comments
        self.score = 1
        self.ups = 1
        self.isSubmitter = false
        self.authorFlairText = nil
        self.authorFlairBackgroundColor = nil
        self.distinguished = nil
        self.stickied = false
        self.likes = true
        self.hasChildren = false
        self.childCount = 0
        self.childIds = []
        
        // Pre-compute formatted values
        self.formattedUps = 1.formatted
        self.timeAgo = created.timeAgo
        
        // Pre-compute colors for placeholder
        self.flairBackgroundColor = .clear
        let safeDepth = max(0, depth - 1)
        self.depthColor = Self.depthColors[safeDepth % Self.depthColors.count]
    }
    
    /// Flatten CommentData directly into Comment array for optimal performance
    static func flattenCommentData(_ commentDataArray: [CommentData]) -> [Comment] {
        var result: [Comment] = []
        
        func collectChildIds(from commentData: CommentData) -> [String] {
            guard case .listing(let listing) = commentData.replies else { return [] }
            
            var childIds: [String] = []
            for child in listing.data.children {
                childIds.append(child.data.id)
                childIds.append(contentsOf: collectChildIds(from: child.data))
            }
            return childIds
        }
        
        func processCommentData(_ commentData: CommentData) {
            let childIds = collectChildIds(from: commentData)
            let childCount = childIds.count
            let hasChildren = childCount > 0
            
            let comment = Comment(
                from: commentData,
                hasChildren: hasChildren,
                childCount: childCount,
                childIds: childIds
            )
            result.append(comment)
            
            // Process children recursively
            if case .listing(let listing) = commentData.replies {
                for child in listing.data.children {
                    processCommentData(child.data)
                }
            }
        }
        
        for commentData in commentDataArray {
            processCommentData(commentData)
        }
        
        return result
    }
    
    /// Filter flat comments based on collapsed state for efficient collapse/expand
    static func applyCollapseState(to comments: [Comment], collapsedIds: Set<String>) -> [Comment] {
        var result: [Comment] = []
        var hiddenIds: Set<String> = Set()
        
        // Collect all IDs that should be hidden due to collapsed parents
        for collapsedId in collapsedIds {
            if let comment = comments.first(where: { $0.id == collapsedId }) {
                hiddenIds.formUnion(comment.childIds)
            }
        }
        
        // Filter out hidden comments
        for comment in comments {
            if !hiddenIds.contains(comment.id) {
                result.append(comment)
            }
        }
        
        return result
    }
}
