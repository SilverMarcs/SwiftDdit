//
//  MediaURLExtractor.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import Foundation

/// Utility for extracting and prefetching image URLs during media processing
struct MediaURLExtractor {    
    /// Extract image URLs from a MediaType and start prefetching immediately
    /// - Parameter mediaType: The MediaType to extract URLs from
    /// - Returns: Array of URLs that were extracted and queued for prefetching
    @discardableResult
    static func extractAndPrefetchURLs(from mediaType: MediaType) -> [URL] {
        return [] // TODO: come back to this
//        let urls = extractImageURLs(from: mediaType)
//        
//        if !urls.isEmpty {
//            // Prefetch immediately for individual posts
//            prefetchImages(urls: urls)
//        }
//        
//        return urls
    }
    
    /// Extract all image URLs from a MediaType
    /// - Parameter mediaType: The MediaType to extract URLs from
    /// - Returns: Array of valid URLs
    static func extractImageURLs(from mediaType: MediaType) -> [URL] {
        var urls: [URL] = []
        
        switch mediaType {
        case .image(let galleryImage):
            if let url = URL(string: galleryImage.url) {
                urls.append(url)
            }
            
        case .gallery(let images):
            for image in images {
                if let url = URL(string: image.url) {
                    urls.append(url)
                }
            }
            
        case .gif(let galleryImage):
            if let url = URL(string: galleryImage.url) {
                urls.append(url)
            }
            
        case .youtube(_, let galleryImage):
            if let url = URL(string: galleryImage.url) {
                urls.append(url)
            }
            
        case .video(_, _, let thumbnailURL):
            if let thumbnailURL = thumbnailURL,
               let url = URL(string: thumbnailURL) {
                urls.append(url)
            }
            
        case .link(let metadata):
            if let thumbnailURL = metadata.thumbnailURL,
               let url = URL(string: thumbnailURL) {
                urls.append(url)
            }
            
        case .repost(let originalPost):
            // Recursively extract URLs from the original post
            let originalURLs = extractImageURLs(from: originalPost.mediaType)
            urls.append(contentsOf: originalURLs)
            
        case .none:
            break
        }
        
        return urls
    }
}
