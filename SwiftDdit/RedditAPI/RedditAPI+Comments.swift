//
//  APICommentFetcher.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import Foundation

extension RedditAPI {
    /// Fetch post with comments
    static func fetchPostWithComments(
        subreddit: String,
        postID: String,
        commentID: String? = nil,
        sort: CommentSortOption = .confidence,
        limit: Int = 100, // TODO: implement infinite scrolling
        depth: Int = 8
    ) async -> (Post?, [Comment], String?)? {
        guard let url = buildCommentsURL(
            subreddit: subreddit,
            postID: postID,
            commentID: commentID,
            sort: sort,
            limit: limit,
            depth: depth
        ) else {
            return nil
        }
        
        guard let response = await performAuthenticatedRequest(url: url, responseType: CommentResponse.self) else {
            return nil
        }
        
        // Extract post data
        let post: Post?
        if let postData = response.postListing.data.children.first?.data {
            post = Post(from: postData)
        } else {
            post = nil
        }
        
        let commentDataArray = response.commentListing.data.children.compactMap { child -> CommentData? in
            guard child.kind == "t1" else { return nil }
            return child.data
        }
        
        let comments = Comment.flattenCommentData(commentDataArray)
        
        return (post, comments, response.after)
    }

    // MARK: - URL Building
    
    static func buildCommentsURL(
        subreddit: String,
        postID: String,
        commentID: String?,
        sort: CommentSortOption,
        limit: Int,
        depth: Int
    ) -> URL? {
        let cleanPostID = postID.hasPrefix("t3_") ? String(postID.dropFirst(3)) : postID
        var urlString = "\(Self.baseURL)/r/\(subreddit)/comments/\(cleanPostID)"
        
        if let commentID = commentID {
            let cleanCommentID = commentID.hasPrefix("t1_") ? String(commentID.dropFirst(3)) : commentID
            urlString += "/comment/\(cleanCommentID)"
        }
        
        urlString += ".json"
        
        var components = URLComponents(string: urlString)
        components?.queryItems = [
            URLQueryItem(name: "sort", value: sort.rawValue),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "depth", value: String(depth)),
            URLQueryItem(name: "raw_json", value: "1")
        ]
        
        return components?.url
    }
    
    // MARK: - Comment Actions
    
    @discardableResult
    static func voteComment(_ action: VoteAction, id: String) async -> Bool {
        guard let url = URL(string: "\(Self.baseURL)/api/vote") else { return false }
        let parameters = "dir=\(action.rawValue)&id=\(id)&api_type=json&raw_json=1"
        return await performPostRequest(url: url, parameters: parameters)
    }
    
    @discardableResult
    static func replyToComment(text: String, parentFullname: String) async -> Bool {
        guard let url = URL(string: "\(Self.baseURL)/api/comment") else { return false }
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let parameters = "api_type=json&text=\(encodedText)&thing_id=\(parentFullname)&raw_json=1"
        return await performPostRequest(url: url, parameters: parameters)
    }
}
