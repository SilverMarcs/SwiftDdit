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
        SMVImage(urlStrings: images.map { $0.url }, targetSize: 600)
            .aspectRatio(images.first?.aspectRatio, contentMode: .fit)
            .cornerRadius(12)
            .clipped()
    }
}
