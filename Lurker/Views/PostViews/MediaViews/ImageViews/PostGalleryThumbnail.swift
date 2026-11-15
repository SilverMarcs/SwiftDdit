//
//  PostGalleryThumbnail.swift
//  Lurker
//

import SwiftUI
import SwiftMediaViewer

/// One square thumbnail in a gallery's thumbnail row. Tapping it opens the
/// gallery's fullscreen viewer on this image.
struct PostGalleryThumbnail: View {
    let url: URL
    /// This image's position in the gallery.
    let index: Int
    /// How many images follow this one without a thumbnail of their own.
    /// When above zero, the count is drawn over the thumbnail.
    var hiddenCount = 0

    var body: some View {
        SMVGalleryItem(index: index) {
            CachedAsyncImage(url: url, targetSize: 1000)
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .overlay {
                    if hiddenCount > 0 {
                        PostGalleryOverflowOverlay(hiddenCount: hiddenCount)
                    }
                }
                .clipShape(.rect(cornerRadius: 8))
        }
    }
}
