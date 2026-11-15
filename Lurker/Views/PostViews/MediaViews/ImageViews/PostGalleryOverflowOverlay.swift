//
//  PostGalleryOverflowOverlay.swift
//  Lurker
//

import SwiftUI

/// The "+N" dimming drawn over a gallery's last thumbnail when more images
/// follow it.
struct PostGalleryOverflowOverlay: View {
    let hiddenCount: Int

    var body: some View {
        Color.black.opacity(0.6)
            .overlay {
                Text("+\(hiddenCount)")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
    }
}
