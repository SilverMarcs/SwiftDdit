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
        SMVGallery(images: images.compactMap { $0.urlObject }, targetSize: 1000)
    }
}
