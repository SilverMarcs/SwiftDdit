//
//  PostGIFView.swift
//  SwiftDdit
//
//  Created for memory optimization -  GIF display
//

import SwiftUI
import WebKit
import SwiftMediaViewer

struct PostGIFView: View {
    @AppStorage("autoplay") var autoplay: Bool = true
    let galleryImage: GalleryImage

    var body: some View {
        SMVGIFView(
            url: galleryImage.urlObject ?? URL(string: galleryImage.url)!,
            autoplay: autoplay,
        )
        .aspectRatio(galleryImage.aspectRatio, contentMode: .fit)
        .cornerRadius(12)
        .clipped()
    }
}
