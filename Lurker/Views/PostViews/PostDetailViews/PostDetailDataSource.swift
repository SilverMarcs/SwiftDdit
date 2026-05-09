//
//  PostDetailDataSource.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import Foundation
import SwiftUI

/// Manages data loading for post detail and comments
@Observable class PostDetailDataSource {
    private(set) var post: Post?
    private(set) var allComments: [Comment] = []
    private(set) var visibleComments: [Comment] = []
    private(set) var collapsedCommentIds: Set<String> = []
    private(set) var isLoading = true
    var sortOption: CommentSortOption = .confidence
    var scrollPosition = ScrollPosition(idType: Comment.ID.self)
    
    @ObservationIgnored private let postNavigation: PostNavigation
    @ObservationIgnored private var hadInitialPost: Bool
    
    init(post: Post) {
        self.postNavigation = PostNavigation(from: post)
        self.post = post
        self.hadInitialPost = true
    }
    
    init(postNavigation: PostNavigation) {
        self.postNavigation = postNavigation
        self.hadInitialPost = false
    }
    
    func updateSort() async {
        allComments = []
        visibleComments = []
        
        // Load if we don't have a post or if comments are empty
        if post == nil || allComments.isEmpty {
            await loadComments()
        }
    }
    
    func loadComments(resetPost: Bool = false) async {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        // Determine which subreddit and post ID to use
        let subredditName: String
        let postId: String
        
        if let post = post {
            // Use existing post data
            subredditName = post.subreddit.displayName
            postId = post.id
        } else if let navSubreddit = postNavigation.subreddit {
            // Use navigation data
            subredditName = navSubreddit
            postId = postNavigation.postId
        } else {
            // Can't proceed without subreddit info
            return
        }
        
        if let result = await RedditAPI.fetchPostWithComments(
            subreddit: subredditName,
            postID: postId,
            sort: sortOption
        ) {
            // Extract post, flat comments, and after token
            let (fetchedPost, fetchedComments, _) = result
            
            // Only update post if we didn't have one initially
            if let fetchedPost = fetchedPost {
                if resetPost || !hadInitialPost {
                    post = fetchedPost
                }
            }
            withAnimation {
                allComments = fetchedComments
                updateVisibleComments()
            } completion: {
                if let commentId = self.postNavigation.commentId {
                    Task {
                        try? await Task.sleep(nanoseconds: 250_000_000)
                        withAnimation {
                            self.scrollPosition.scrollTo(id: commentId, anchor: .bottom)
                        }
                    }
                }
            }
        } else {
            print("PostDetailDataSource: Failed to fetch post with comments")
        }
    }
    
    func toggleCommentCollapse(_ commentId: String) {
        if collapsedCommentIds.contains(commentId) {
            collapsedCommentIds.remove(commentId)
        } else {
            collapsedCommentIds.insert(commentId)
        }
        
        updateVisibleComments()
    }
    
    func addOptimisticComment(text: String, parentId: String) {
        let fakeId = "temp_\(UUID().uuidString)"
        
        // Find the parent comment in visibleComments to get its depth
        guard let parentIndex = visibleComments.firstIndex(where: { $0.id == parentId }) else {
            print("Could not find parent comment with id: \(parentId)")
            return
        }
        
        let parentComment = visibleComments[parentIndex]
        
        // Create optimistic flat comment
        let optimisticComment = Comment(
            id: fakeId,
            author: CredentialsManager.shared.credential?.userName ?? "You",
            body: text,
            depth: parentComment.depth + 1,
            parentID: "t1_\(parentId)"
        )
        
        // Insert the new comment right after the parent comment
        visibleComments.insert(optimisticComment, at: parentIndex + 1)
        allComments.insert(optimisticComment, at: allComments.firstIndex(where: { $0.id == parentId })! + 1)
        
        // Fire off the network request in the background
        Task {
            _ = await RedditAPI.replyToComment(text: text, parentFullname: "t1_\(parentId)")
        }
    }
    
    func addOptimisticTopLevelComment(text: String, postId: String) {
        let fakeId = "temp_\(UUID().uuidString)"
        
        // Create optimistic top-level comment
        let optimisticComment = Comment(
            id: fakeId,
            author: CredentialsManager.shared.credential?.userName ?? "You",
            body: text,
            depth: 0,
            parentID: "t3_\(postId)"
        )
        
        // Insert the new comment at the top of the list
        visibleComments.insert(optimisticComment, at: 0)
        allComments.insert(optimisticComment, at: 0)
        
        // Fire off the network request in the background
        Task {
            _ = await RedditAPI.replyToComment(text: text, parentFullname: "t3_\(postId)")
        }
    }
    
    private func updateVisibleComments() {
        visibleComments = Comment.applyCollapseState(to: allComments, collapsedIds: collapsedCommentIds)
    }
    
    var commentId: String? {
        postNavigation.commentId
    }
}
