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
    
    // Define grid layout
    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 80), spacing: 4)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main image display (always first image)
            if let firstImage = images.first {
                SMVImage(url: firstImage.url, allURLs: images.map { $0.url }, targetSize: 600)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .clipped()
            }
            
            // Thumbnails (next 3 images)
            if images.count > 1 {
                let remainingImages = Array(images.dropFirst())
                let displayImages = Array(remainingImages.prefix(3))
                let remainingCount = remainingImages.count - displayImages.count
                
                HStack(spacing: 8) {
                    ForEach(Array(displayImages.enumerated()), id: \.offset) { index, image in
                        SMVImage(url: image.url, allURLs: images.map { $0.url }, targetSize: 600)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .clipped()
                            .overlay {
                                if index == displayImages.count - 1 && remainingCount > 0 {
                                    Rectangle()
                                        .fill(.black.opacity(0.6))
                                        .cornerRadius(8)
                                        .overlay {
                                            Text("+\(remainingCount)")
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.white)
                                        }
                                }
                            }
                    }
                }
            }
        }
    }
}
