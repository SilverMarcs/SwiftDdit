import SwiftUI
import SwiftMediaViewer

struct PostVideoView: View {
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = true
    
    let videoURL: String
    let dimensions: CGSize?
    let thumbnailURL: String?
    
    @State private var showVideo = false
    
    private static func safeAspectRatio(from dimensions: CGSize?) -> CGFloat {
        guard let d = dimensions, d.width > 0, d.height > 0 else { return 16.0 / 9.0 }
        let ratio = d.width / d.height
        return ratio.isFinite && ratio > 0 ? ratio : 16.0 / 9.0
    }

    var body: some View {
        Group {
            if autoplay || showVideo {
                SMVVideo(videoURL: videoURL, autoplay: true, muteOnPlay: muteOnPlay)
            } else {
                Button(action: {
                    showVideo = true
                }) {
                    CachedAsyncImage(url: URL(string: thumbnailURL ?? ""), targetSize: 450)
                        .overlay(
                            Image(systemName: "play.fill")
                                .imageScale(.large)
                                .padding()
                                .glassEffect(in: .circle)
                                .foregroundStyle(.white)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(.rect(cornerRadius: 12))
        .aspectRatio(Self.safeAspectRatio(from: dimensions), contentMode: .fit)
    }
}
