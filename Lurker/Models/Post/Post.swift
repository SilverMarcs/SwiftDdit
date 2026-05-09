//
//  Post.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 16/06/25.
//

import Foundation
import SwiftUI

/// Contains only essential information needed for basic post display
struct Post: Identifiable, Hashable, Equatable, Votable {
    let id: String
    let title: String
    let author: String
    let subreddit: Subreddit
    let ups: Int
    let numComments: Int
    let created: Double
    let permalink: String
    let fullname: String
    let isNSFW: Bool
    let isSelf: Bool
    let thumbnail: String?
    let linkFlairText: String?
    let selftext: String
    let downs: Int
    let linkFlairTextColor: String?
    let linkFlairBackgroundColor: String?
    let over18: Bool?
    var saved: Bool
    let likes: Bool?
    
    let mediaType: MediaType
    
    // Pre-computed formatted values
    let formattedUps: String
    let formattedNumComments: String
    let timeAgo: String
    
    // Pre-computed colors
    let flairBackgroundColor: Color
    let flairTextColor: Color
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
    
    init(from postData: PostData) {
        self.id = postData.id
        self.title = postData.title
        self.author = postData.author
        
        if let srDetail = postData.sr_detail {
            self.subreddit = Subreddit(detail: srDetail)
        } else {
            self.subreddit = Subreddit(
                displayName: postData.subreddit
            )
        }
        
        self.ups = postData.ups
        self.numComments = postData.num_comments
        self.created = postData.created
        self.permalink = postData.permalink
        self.fullname = postData.name
        self.isNSFW = postData.over_18 ?? false
        self.isSelf = postData.is_self
        self.thumbnail = postData.thumbnail
        self.linkFlairText = postData.link_flair_text
        self.selftext = postData.selftext
        self.downs = postData.downs
        self.linkFlairTextColor = postData.link_flair_text_color
        self.linkFlairBackgroundColor = postData.link_flair_background_color
        self.over18 = postData.over_18
        self.saved = postData.saved
        self.likes = postData.likes
        
        // Pre-compute formatted values
        self.formattedUps = postData.ups.formatted
        self.formattedNumComments = postData.num_comments.formatted
        self.timeAgo = postData.created.timeAgo
        
        // Pre-compute media type
        self.mediaType = Post.extractMedia(from: postData)
        
        // Pre-compute flair background color
        if let bgColor = postData.link_flair_background_color,
           !bgColor.isEmpty {
            self.flairBackgroundColor = Color(hex: bgColor)
        } else {
            self.flairBackgroundColor = Color(hex: "D5D7D9") // Default light gray
        }
        
        // Pre-compute flair text color
        let hasBackground = postData.link_flair_background_color != nil &&
                          !postData.link_flair_background_color!.isEmpty
        
        if hasBackground, let textColor = postData.link_flair_text_color {
            self.flairTextColor = textColor == "light" ? .white : .black
        } else {
            self.flairTextColor = .black // Default
        }
    }
    
    /// Full Reddit URL for sharing
    var redditURL: URL? {
        return URL(string: "https://reddit.com\(permalink)")
    }
}
