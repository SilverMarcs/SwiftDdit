//
//  PostImageView.swift
//  SwiftDdit
//
//  Created for memory optimization -  image display
//

import SwiftUI
import CachedAsyncImage

struct PostImageView: View {
    var image: GalleryImage
    
    @Environment(\.imageNS) private var imageNS
    @Namespace private var fallbackNS
    
    @State var imageModalData: ImageModalData? = nil
    
    var body: some View {
        if let url = URL(string: image.url) {
            Button {
                imageModalData = ImageModalData(image: image)
            } label: {
                CachedAsyncImage(url: url, targetSize: 500)
                    .aspectRatio(image.aspectRatio, contentMode: .fit)
                    .matchedTransitionSource(id: image.url, in: imageNS ?? fallbackNS)
                    .cornerRadius(12)
                    .clipped()
            }
            .buttonStyle(.plain)
            .fullScreenCover(item: $imageModalData) { data in
                ImageModal(imageData: data)
            }
        }
    }
}

#Preview {
    PostImageView(
        image: .init(url: "https://example.com/image.jpg", dimensions: CGSize(width: 800, height: 600))
    )
    .padding()
}
