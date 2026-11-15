//
//  PostGalleryView.swift
//  SwiftDdit
//
//  Created for memory optimization -  gallery display
//

import SwiftUI
import SwiftMediaViewer

/// A post's image gallery: a lead image over a row of up to three
/// thumbnails. Tapping any image opens the fullscreen viewer on that image,
/// and the viewer pages through every image in the post.
struct PostGalleryView: View {
    let images: [GalleryImage]

    var body: some View {
        let urls = images.compactMap(\.urlObject)

        SMVGallery(images: urls, targetSize: 1000) {
            VStack(alignment: .leading, spacing: 8) {
                if let leadURL = urls.first {
                    SMVGalleryItem(index: 0) {
                        CachedAsyncImage(url: leadURL, targetSize: 1000)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                }

                if urls.count > 1 {
                    PostGalleryThumbnailRow(urls: urls)
                }
            }
        }
    }
}
