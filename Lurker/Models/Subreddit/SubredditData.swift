//
//  SubredditData.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

/// SubredditData structure matching Reddit API
struct SubredditData: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let display_name: String?
    let display_name_prefixed: String?
    let title: String?
    let public_description: String
    let description: String?
    let subscribers: Int?
    let active_user_count: Int?
    let over18: Bool?
    let icon_img: String?
    let community_icon: String?
    let banner_img: String?
    let primary_color: String?
    let key_color: String?
    let header_img: String?
    let created: Double?
    let created_utc: Double?
    let subreddit_type: String
    let user_is_subscriber: Bool?
    let user_is_moderator: Bool?
    let user_is_banned: Bool?
    let user_has_favorited: Bool?
    let allow_images: Bool?
    let allow_videos: Bool?
    let allow_galleries: Bool?
    let allow_polls: Bool?
    let restrict_posting: Bool?
    let restrict_commenting: Bool?
    let wiki_enabled: Bool?
    let quarantine: Bool?
    let hide_ads: Bool?
    let show_media: Bool?
    let show_media_preview: Bool?
    let spoilers_enabled: Bool?
    let allow_talks: Bool?
    let url: String
}
