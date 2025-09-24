//
//  SaveImageButton.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import Photos
import CachedAsyncImage

#if os(iOS)
  import UIKit
  typealias OSImage = UIImage
#elseif os(macOS)
  import AppKit
  typealias OSImage = NSImage
#endif

struct SaveImageButton: View {
  let imageURL: String
  @State private var isSaving = false

  var body: some View {
    Button {
      Task { await saveImage() }
    } label: {
      Image(systemName: isSaving ? "checkmark" : "arrow.down")
        .foregroundStyle(isSaving ? .green : .primary)
    }
    .buttonStyle(.glass)
    .disabled(isSaving)
  }

  private func saveImage() async {
    guard let url = URL(string: imageURL) else { return }

    isSaving = true
    defer { isSaving = false }

    do {
      // 1) Try cache first
      let image: OSImage
      if let cached = await MemoryCache.shared.get(for: imageURL) {
        image = cached
      } else {
        // 2) Otherwise download
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let ui = OSImage(data: data) else {
          throw NSError(domain: "SaveImage", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }
        image = ui
      }

      // 3) Write into the Photos library
      try await PHPhotoLibrary.shared().performChanges {
        @Sendable in
        PHAssetChangeRequest.creationRequestForAsset(from: image)
      }

      // (optional) brief success feedback
      try? await Task.sleep(nanoseconds: 500_000_000)
    }
    catch {
      print("❌ Failed to save image:", error)
    }
  }
}
