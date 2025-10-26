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
        if let url = image.urlObject {
            SMVImage(url: url, targetSize: 1000)
                .aspectRatio(image.aspectRatio, contentMode: .fit)
                .cornerRadius(12)
                .clipped()
        }
    }
}
