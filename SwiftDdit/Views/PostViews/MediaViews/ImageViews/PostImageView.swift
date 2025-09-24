//
//  PostImageView.swift
//  SwiftDdit
//
//  Created for memory optimization -  image display
//

import SwiftUI
import SwiftMediaViewer

struct PostImageView: View {
    var image: GalleryImage
    
    var body: some View {
        SMVImage(url: image.url, targetSize: 600)
            // Apply the same visual modifiers as before from the app side
            .aspectRatio(image.aspectRatio, contentMode: .fit)
            .cornerRadius(12)
            .clipped()
    }
}
