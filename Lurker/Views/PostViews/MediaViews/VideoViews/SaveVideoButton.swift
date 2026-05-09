//
//  SaveVideoButton.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import PhotosUI

struct SaveVideoButton: View {
    let videoURL: String
    @Binding var isSaving: Bool
    
    var body: some View {
        Button {
            Task {
                await saveVideo()
            }
        } label: {
            Image(systemName: isSaving ? "checkmark" : "arrow.down")
        }
        .buttonStyle(.glass)
        .controlSize(.large)
        .disabled(isSaving)
    }
    
    private func saveVideo() async {
        guard let url = URL(string: videoURL) else { return }
        
        isSaving = true
        defer { isSaving = false }
        
        do {
            let (localURL, _) = try await URLSession.shared.download(from: url)
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsDirectory.appendingPathComponent("tempVideo.mp4")
            
            try? FileManager.default.removeItem(at: destinationURL)
            try FileManager.default.copyItem(at: localURL, to: destinationURL)
            
            try await PHPhotoLibrary.shared().performChanges({ [destinationURL] in
                guard PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL) != nil else {
                    print("Failed to create asset request")
                    return
                }
            } as @Sendable () -> Void)
            
            try? FileManager.default.removeItem(at: destinationURL)
            
        } catch {
            print("Failed to save video: \(error)")
        }
    }
}
