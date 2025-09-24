//
//  PostGalleryView.swift
//  SwiftDdit
//
//  Created for memory optimization -  gallery display
//

import SwiftUI
import SwiftMediaViewer

struct PostGalleryView: View {
    let images: [GalleryImage]
     
    var body: some View {
        SMVGallery(
              images: images.map { $0.url },
              layout: .mainWithThumbs(thumbSize: 80, maxThumbs: 3),
              targetSize: 600
          )
    }
}
