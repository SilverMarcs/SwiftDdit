//
//  PostGalleryThumbnailRow.swift
//  Lurker
//

import SwiftUI

/// The thumbnails under a gallery's lead image: images 1...3, with a count of
/// any further images over the last one.
struct PostGalleryThumbnailRow: View {
    /// Every image in the gallery, including the lead image at index 0.
    let urls: [URL]

    /// The most thumbnails shown before the rest collapse into a count.
    private let maxThumbnails = 3

    var body: some View {
        let lastShownIndex = min(urls.count - 1, maxThumbnails)
        let hiddenCount = urls.count - 1 - lastShownIndex

        HStack(spacing: 8) {
            ForEach(urls.indices.dropFirst().prefix(maxThumbnails), id: \.self) { index in
                PostGalleryThumbnail(
                    url: urls[index],
                    index: index,
                    hiddenCount: index == lastShownIndex ? hiddenCount : 0
                )
            }
        }
    }
}
