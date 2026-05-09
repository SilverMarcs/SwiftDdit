//
//  PostData.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

/// Core PostData structure matching Reddit's API response
struct PostData: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let author: String
    let subreddit: String
    let subreddit_name_prefixed: String
    let ups: Int
    let downs: Int
    let num_comments: Int
    let created: Double
    let permalink: String
    let name: String
    let url: String
    let domain: String
    let is_self: Bool
    let selftext: String
    let clicked: Bool
    let saved: Bool
    let hidden: Bool
    let gilded: Int
    let hide_score: Bool
    let quarantine: Bool
    let upvote_ratio: Double
    let subreddit_type: String
    let total_awards_received: Int
    let allow_live_comments: Bool
    let is_robot_indexable: Bool
    let send_replies: Bool
    let contest_mode: Bool
    let subreddit_subscribers: Int
    let num_crossposts: Int
    
    // Optional properties
    let created_utc: Double?
    let post_hint: String?
    let thumbnail: String?
    let link_flair_text: String?
    let link_flair_text_color: String?
    let whitelist_status: String?
    let link_flair_background_color: String?
    let link_flair_type: String?
    let approved_at_utc: Int?
    let mod_reason_title: String?
    let top_awarded_type: String?
    let author_flair_background_color: String?
    let approved_by: String?
    let is_created_from_ads_ui: Bool?
    let author_premium: Bool?
    let author_flair_css_class: String?
    let author_flair_type: String?
    let likes: Bool?
    let stickied: Bool?
    let suggested_sort: String?
    let banned_at_utc: String?
    let view_count: String?
    let archived: Bool?
    let no_follow: Bool?
    let is_crosspostable: Bool?
    let pinned: Bool?
    let over_18: Bool?
    let media_only: Bool?
    let can_gild: Bool?
    let spoiler: Bool?
    let locked: Bool?
    let treatment_tags: [String]?
    let visited: Bool?
    let removed_by: String?
    let num_reports: Int?
    let distinguished: String?
    let subreddit_id: String?
    let author_is_blocked: Bool?
    let mod_reason_by: String?
    let removal_reason: String?
    let report_reasons: [String]?
    let discussion_type: String?
    let is_video: Bool?
    let is_gallery: Bool?

    // Crosspost/Repost support
    let crosspost_parent_list: [PostData]?

    // Subreddit details (when sr_detail=1)
    let sr_detail: SubredditDetail?
    
    // Media-related fields for high-quality images
    let preview: Preview?
    let media: Media?
    let gallery_data: GalleryData?
    let media_metadata: [String: MediaMetadataItem?]?
}

// MARK: - Preview Support for High-Quality Images

struct PreviewImg: Codable, Hashable {
    let url: String?
    let width: Int?
    let height: Int?
}

struct PreviewImgCollection: Codable, Hashable {
    let source: PreviewImg?
    let resolutions: [PreviewImg]?
}

struct RedditVideoPreview: Codable, Hashable {
    let bitrate_kbps: Double?
    let fallback_url: String?
    let height: Double?
    let width: Double?
    let scrubber_media_url: String?
    let dash_url: String?
    let duration: Double?
    let hls_url: String?
    let is_gif: Bool?
    let transcoding_status: String?
}

struct Preview: Codable, Hashable {
    let images: [PreviewImgCollection]?
    let reddit_video_preview: RedditVideoPreview?
    let enabled: Bool?
}

struct Media: Codable, Hashable {
    let type: String?
    let oembed: Oembed?
    let reddit_video: RedditVideo?
}

struct Oembed: Codable, Hashable {
    let provider_url: String?
    let version: String?
    let title: String?
    let type: String?
    let thumbnail_width: Int?
    let height: Int?
    let width: Int?
    let html: String?
    let author_name: String?
    let provider_name: String?
    let thumbnail_url: String?
    let thumbnail_height: Int?
    let author_url: String?
}

struct RedditVideo: Codable, Hashable {
    let bitrate_kbps: Double?
    let fallback_url: String?
    let height: Double?
    let width: Double?
    let scrubber_media_url: String?
    let dash_url: String?
    let duration: Double?
    let hls_url: String?
    let is_gif: Bool?
    let transcoding_status: String?
}

struct GalleryData: Codable, Hashable {
    let items: [GalleryDataItem]?
}

struct GalleryDataItem: Codable, Hashable, Identifiable {
    let media_id: String
    let id: Double
}

struct MediaMetadataItem: Codable, Hashable, Identifiable {
    let status: String
    let e: String?
    let m: String?
    let p: [MediaMetadataItemSize]?
    let s: MediaMetadataItemSize?
    let id: String?
}

struct MediaMetadataItemSize: Codable, Hashable {
    let x: Int
    let y: Int
    let u: String?
}

// MARK: - Subreddit Detail Support

struct SubredditDetail: Codable, Hashable {
    let name: String // Full name like "t5_12hozx"
    let display_name: String?
    let display_name_prefixed: String?
    let community_icon: String?
    let icon_img: String?
    let public_description: String?
    let subscribers: Int?
    let over_18: Bool?
    let user_is_subscriber: Bool?
    let subreddit_type: String?
    let created_utc: Double?
    let title: String?
    let url: String?
    let description: String?
    let banner_img: String?
    let key_color: String?
    let primary_color: String?
    let quarantine: Bool?
    let user_is_moderator: Bool?
    let user_is_banned: Bool?
    let user_is_contributor: Bool?
    let user_is_muted: Bool?
    
    /// Extract the actual ID from the full name (e.g., "12hozx" from "t5_12hozx")
    var id: String {
        if name.hasPrefix("t5_") {
            return String(name.dropFirst(3)) // Remove "t5_" prefix
        }
        return name
    }
}
