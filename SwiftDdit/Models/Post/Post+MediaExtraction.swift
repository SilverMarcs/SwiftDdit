//
//  Post+MediaExtraction.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 19/06/25.
//

import Foundation
import SwiftUI

// MARK: - Media Extraction Extension
extension Post {
    ///  media extraction that determines media type with high-quality URLs and dimensions
    static func extractMedia(from data: PostData) -> MediaType {
        // Skip self posts
        guard !data.is_self else { return .none }
        
        // PRIORITY 0: Check for crosspost/repost first
        if let crosspostParentList = data.crosspost_parent_list,
           let originalPostData = crosspostParentList.first {
            let originalPost = Post(from: originalPostData)
            let mediaType = MediaType.repost(originalPost: originalPost)
            
            // Prefetch images from the repost immediately
            MediaURLExtractor.extractAndPrefetchURLs(from: mediaType)
            
            return mediaType
        }
        
        let url = data.url
        let domain = data.domain
        
        // PRIORITY 1: Gallery detection (store all high-quality images)
        if let isGallery = data.is_gallery, isGallery,
           let galleryData = data.gallery_data?.items, 
           let metadata = data.media_metadata {
            
            let galleryImages = extractAllGalleryImages(from: galleryData, metadata: metadata)
            
            if !galleryImages.isEmpty {
                let mediaType = MediaType.gallery(galleryImages: galleryImages)
                
                // Prefetch all gallery images immediately
                MediaURLExtractor.extractAndPrefetchURLs(from: mediaType)
                
                return mediaType
            }
        }
        
        // PRIORITY 2: Reddit Video (HLS for high quality)
        if let videoPreview = data.preview?.reddit_video_preview,
           let hlsURL = videoPreview.hls_url {
            
            let dimensions = (videoPreview.width != nil && videoPreview.height != nil) ? 
                CGSize(width: videoPreview.width!, height: videoPreview.height!) : nil
            let (thumbnailURL, _) = extractHighQualityImageWithDimensions(from: data)
            let mediaType = MediaType.video(videoURL: hlsURL, dimensions: dimensions, thumbnailURL: thumbnailURL)
            
            // Prefetch video thumbnail immediately
            MediaURLExtractor.extractAndPrefetchURLs(from: mediaType)
            
            return mediaType
        }
        
        if let redditVideo = data.media?.reddit_video,
           let hlsURL = redditVideo.hls_url {
            
            let dimensions = (redditVideo.width != nil && redditVideo.height != nil) ? 
                CGSize(width: redditVideo.width!, height: redditVideo.height!) : nil
            let (thumbnailURL, _) = extractHighQualityImageWithDimensions(from: data)
            let mediaType = MediaType.video(videoURL: hlsURL, dimensions: dimensions, thumbnailURL: thumbnailURL)
            
            // Prefetch video thumbnail immediately
            MediaURLExtractor.extractAndPrefetchURLs(from: mediaType)
            
            return mediaType
        }
        
        // PRIORITY 3: YouTube Videos
        if domain.contains("youtube.com") || domain.contains("youtu.be") {
            if let oembed = data.media?.oembed,
               let html = oembed.html,
               let videoID = extractYouTubeID(from: html),
               let width = oembed.width,
               let height = oembed.height {
                
                let thumbnailURL = oembed.thumbnail_url ?? extractImageURL(from: data)
                if let galleryImage = createGalleryImage(
                    url: thumbnailURL,
                    dimensions: CGSize(width: width, height: height)
                ) {
                    let mediaType = MediaType.youtube(videoID: videoID, galleryImage: galleryImage)
                    
                    // Prefetch YouTube thumbnail immediately
                    MediaURLExtractor.extractAndPrefetchURLs(from: mediaType)
                    
                    return mediaType
                }
            }
            
            // Fallback for YouTube URLs without oembed
            if let videoID = extractYouTubeIDFromURL(url) {
                let thumbnailURL = "https://img.youtube.com/vi/\(videoID)/maxresdefault.jpg"
                if let galleryImage = createGalleryImage(
                    url: thumbnailURL,
                    dimensions: nil
                ) {
                    let mediaType = MediaType.youtube(videoID: videoID, galleryImage: galleryImage)
                    
                    // Prefetch YouTube thumbnail immediately
                    MediaURLExtractor.extractAndPrefetchURLs(from: mediaType)
                    
                    return mediaType
                }
            }
        }
        
        // PRIORITY 4: Direct video files
        let videoFormats = [".mov", ".mp4", ".avi", ".mkv", ".flv", ".wmv", ".mpg", ".mpeg", ".webm"]
        if videoFormats.contains(where: { url.hasSuffix($0) }) {
            let mediaType = MediaType.video(videoURL: url, dimensions: nil, thumbnailURL: nil)
            
            // Prefetch video thumbnail immediately
            MediaURLExtractor.extractAndPrefetchURLs(from: mediaType)
            
            return mediaType
        }
        
        // PRIORITY 5: GIF detection (including animated) - improved detection
        if url.hasSuffix(".gif") || 
           url.hasSuffix(".gifv") ||
           domain.contains("gfycat") || 
           domain.contains("redgifs") ||
           (domain.contains("imgur") && (url.contains("gif") || url.contains("gifv"))) {
            let (imageURL, dimensions) = extractHighQualityImageWithDimensions(from: data)
            if let galleryImage = createGalleryImage(url: imageURL, dimensions: dimensions) {
                let mediaType = MediaType.gif(galleryImage: galleryImage)
                
                // Prefetch GIF image immediately
                MediaURLExtractor.extractAndPrefetchURLs(from: mediaType)
                
                return mediaType
            }
        }
        
        // PRIORITY 6: Direct image formats
        let imageFormats = [".gif", ".png", ".jpg", ".jpeg", ".webp", ".bmp", ".tiff", ".svg", ".ico", ".heic", ".heif"]
        if imageFormats.contains(where: { url.hasSuffix($0) }) || 
           domain.contains("i.redd.it") || domain.contains("i.imgur.com") {
            let (imageURL, dimensions) = extractHighQualityImageWithDimensions(from: data)
            if let galleryImage = createGalleryImage(url: imageURL, dimensions: dimensions) {
                let mediaType = MediaType.image(galleryImage: galleryImage)
                
                // Prefetch image immediately
                MediaURLExtractor.extractAndPrefetchURLs(from: mediaType)
                
                return mediaType
            }
        }
        
        // PRIORITY 7: Preview images (high quality conversion) - Better detection
        if let preview = data.preview,
           let images = preview.images,
           !images.isEmpty {
            let (imageURL, dimensions) = extractHighQualityImageWithDimensions(from: data)
            if let imageURL = imageURL {
                // Check if this is actually an image or just a link preview
                let imageFormats = [".gif", ".png", ".jpg", ".jpeg", ".webp", ".bmp", ".tiff", ".svg", ".ico", ".heic", ".heif"]
                let isDirectImage = imageFormats.contains(where: { url.hasSuffix($0) }) || 
                                  url.contains("i.redd.it") || url.contains("i.imgur.com")
                
                if isDirectImage, let galleryImage = createGalleryImage(url: imageURL, dimensions: dimensions) {
                    let mediaType = MediaType.image(galleryImage: galleryImage)
                    
                    // Prefetch preview image immediately
                    MediaURLExtractor.extractAndPrefetchURLs(from: mediaType)
                    
                    return mediaType
                }
            }
        }
        
        // PRIORITY 8: External links with rich metadata - extract from any domain
        if !url.isEmpty && url != data.permalink && !data.is_self {
            let linkMetadata = extractLinkMetadata(from: data)
            let mediaType = MediaType.link(metadata: linkMetadata)
            
            // Prefetch link thumbnail if available immediately
            MediaURLExtractor.extractAndPrefetchURLs(from: mediaType)
            
            return mediaType
        }
        
        return .none
    }
    
    /// Extract high-quality image URL with dimensions from PostData
    private static func extractHighQualityImageWithDimensions(from data: PostData) -> (url: String?, dimensions: CGSize?) {
        var imageURL: String? = nil
        var dimensions: CGSize? = nil
        
        // Priority 1: High-quality preview image with dimensions
        if let preview = data.preview,
           let images = preview.images,
           !images.isEmpty,
           let source = images[0].source,
           let url = source.url,
           let width = source.width,
           let height = source.height {
            
            // Convert preview URL to high-quality i.redd.it URL
            let cleanURL = url
                .replacingOccurrences(of: "/preview.", with: "/i.")
                .replacingOccurrences(of: "&amp;", with: "&")
            
            // Skip external preview URLs as they're often low quality
            if !cleanURL.contains("external-preview") {
                imageURL = cleanURL
                dimensions = CGSize(width: width, height: height)
            }
        }
        
        // Priority 2: Direct image URLs (i.redd.it, i.imgur.com, etc.)
        if imageURL == nil {
            let url = data.url
            if url.contains("i.redd.it") || url.contains("i.imgur.com") ||
               url.hasSuffix(".jpg") || url.hasSuffix(".jpeg") || 
               url.hasSuffix(".png") || url.hasSuffix(".webp") ||
               url.hasSuffix(".gif") {
                imageURL = url
                // Try to get dimensions from preview if available
                if let preview = data.preview,
                   let images = preview.images,
                   !images.isEmpty,
                   let source = images[0].source,
                   let width = source.width,
                   let height = source.height {
                    dimensions = CGSize(width: width, height: height)
                }
            }
        }
        
        // Priority 3: Fallback to thumbnail if available and decent quality
        if imageURL == nil {
            let thumbnail = data.thumbnail
            if let thumbnail = thumbnail,
               thumbnail != "self" &&
               thumbnail != "default" &&
               thumbnail != "nsfw" &&
               thumbnail != "" &&
               thumbnail.starts(with: "http") &&
               !thumbnail.contains("b.thumbs.redditmedia.com") { // Skip low-quality thumbnails
                imageURL = thumbnail
            }
        }
        
        return (imageURL, dimensions)
    }
    
    /// Extract all gallery images with high-quality URLs and dimensions
    private static func extractAllGalleryImages(from galleryData: [GalleryDataItem], metadata: [String: MediaMetadataItem?]) -> [GalleryImage] {
        return galleryData.compactMap { item in
            let mediaId = item.media_id
            if let itemMeta = metadata[mediaId],
               let extArray = itemMeta?.m?.split(separator: "/"),
               let ext = extArray.last,
               let size = itemMeta?.s {
                
                let url = "https://i.redd.it/\(mediaId).\(ext)"
                let dimensions = CGSize(width: size.x, height: size.y)
                return GalleryImage(url: url, dimensions: dimensions)
            }
            return nil
        }
    }
    
    /// Create a GalleryImage from URL and dimensions
    private static func createGalleryImage(url: String?, dimensions: CGSize?) -> GalleryImage? {
        guard let url = url else { return nil }
        let size = dimensions ?? CGSize(width: 0, height: 0)
        return GalleryImage(url: url, dimensions: size)
    }
    
    /// Extract best quality thumbnail URL for links
    private static func extractBestThumbnailURL(from data: PostData) -> String? {
        // Priority 1: High-quality preview thumbnail (but not external-preview)
        if let preview = data.preview,
           let images = preview.images,
           !images.isEmpty,
           let source = images[0].source,
           let url = source.url {
            
            let cleanURL = url
                .replacingOccurrences(of: "/preview.", with: "/i.")
                .replacingOccurrences(of: "&amp;", with: "&")
            
            // Accept even external previews for links if they're decent quality
            if !cleanURL.contains("external-preview") || cleanURL.contains("format=") {
                return cleanURL
            }
        }
        
        // Priority 2: Regular thumbnail if it's not a default/placeholder
        let thumbnail = data.thumbnail
        if let thumbnail = thumbnail,
           thumbnail != "self" &&
           thumbnail != "default" &&
           thumbnail != "nsfw" &&
           thumbnail != "" &&
           thumbnail.starts(with: "http") {
            return thumbnail
        }
        
        return nil
    }
    
    /// Extract YouTube video ID from oembed HTML
    private static func extractYouTubeID(from html: String) -> String? {
        let pattern = "(?<=www\\.youtube\\.com/embed/)[^?]*"
        let regex = try? NSRegularExpression(pattern: pattern)
        return regex?.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.count)).map {
            String(html[Range($0.range, in: html)!])
        }
    }
    
    /// Extract YouTube video ID from URL patterns
    private static func extractYouTubeIDFromURL(_ url: String) -> String? {
        let patterns = [
            "(?<=watch\\?v=)[^&]*",           // youtube.com/watch?v=VIDEO_ID
            "(?<=youtu\\.be/)[^?]*",         // youtu.be/VIDEO_ID
            "(?<=embed/)[^?]*"               // youtube.com/embed/VIDEO_ID
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, options: [], range: NSRange(location: 0, length: url.count)) {
                return String(url[Range(match.range, in: url)!])
            }
        }
        return nil
    }
    
    /// Extract basic image URL from PostData (for backward compatibility)
    private static func extractImageURL(from data: PostData) -> String? {
        let (url, _) = extractHighQualityImageWithDimensions(from: data)
        return url
    }

    /// Extract rich link metadata from PostData
    private static func extractLinkMetadata(from data: PostData) -> LinkMetadata {
        let url = data.url
        let domain = data.domain
        
        // Get the best available thumbnail
        let thumbnailURL = extractBestThumbnailURL(from: data)
        
        return LinkMetadata(
            url: url,
            domain: domain,
            thumbnailURL: thumbnailURL
        )
    }
}
