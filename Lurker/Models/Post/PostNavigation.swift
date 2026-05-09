//
//  PostNavigation.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import Foundation

struct PostNavigation: Hashable, Codable {
    let postId: String
    let subreddit: String?
    let commentId: String?
    
    init(postId: String, subreddit: String? = nil, commentId: String? = nil) {
        self.postId = postId
        self.subreddit = subreddit
        self.commentId = commentId
    }
    
    init(from post: Post) {
        self.postId = post.id
        self.subreddit = post.subreddit.displayName
        self.commentId = nil
    }
}

extension Message {
    var postNavigation: PostNavigation? {
        // Only navigate for post and comment replies
        guard type == "post_reply" || type == "comment_reply" else { return nil }
        
        // Extract post ID from parent_id or context
        let postId: String
        
        if type == "post_reply", let parentId = parentId {
            // For post replies, parent_id is the post (format: "t3_postid")
            postId = String(parentId.dropFirst(3)) // Remove "t3_" prefix
        } else if let context = context {
            // For comment replies, extract from context URL
            let components = context.components(separatedBy: "/")
            guard components.count >= 5, components[4] != "" else { return nil }
            postId = components[4]
        } else {
            return nil
        }
        
        return PostNavigation(
            postId: postId,
            subreddit: subreddit,
            commentId: id
        )
    }
}
