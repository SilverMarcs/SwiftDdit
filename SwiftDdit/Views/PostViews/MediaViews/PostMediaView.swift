//
//  PostMediaView.swift
//  SwiftDdit
//
//  Created for memory optimization -  media display
//

import SwiftUI

struct PostMediaView: View {
  let mediaType: MediaType
  
  var body: some View {
      switch mediaType {
      case .none:
        EmptyView()
        
      case .image(let galleryImage):
          PostImageView(image: galleryImage)
        
      case .gallery(let images):
          PostGalleryView(images: images)
        
      case .video(let videoURL, let dimensions):
           PostVideoView(videoURL: videoURL, dimensions: dimensions)
        
      case .youtube(let videoID, let galleryImage):
          PostYouTubeView(videoID: videoID, galleryImage: galleryImage)
        
      case .gif(let galleryImage):
          PostGIFView(galleryImage: galleryImage)
        
      case .repost(let originalPost):
          PostRepostView(originalPost: originalPost)
        
      case .link(let metadata):
          PostLinkView(metadata: metadata)
      }
    }
}
