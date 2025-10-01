import SwiftUI
import SwiftMediaViewer

struct PostVideoView: View {
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = true
    
    let videoURL: String
    let dimensions: CGSize?
    let thumbnailURL: String?
    
    @State private var showVideo = false
    
    var body: some View {
        Group {
            if autoplay || showVideo {
                SMVVideo(videoURL: videoURL, autoplay: true, muteOnPlay: muteOnPlay)
            } else {
                CachedAsyncImage(url: URL(string: thumbnailURL ?? ""), targetSize: 450)
                    .overlay(
                        Image(systemName: "play.fill")
                            .imageScale(.large)
                            .padding()
                            .glassEffect(in: .circle)
                            .foregroundStyle(.white)
                    )
                    .onTapGesture {
                        showVideo = true
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .aspectRatio(dimensions != nil ? (dimensions!.width / dimensions!.height) : 16/9, contentMode: .fit)
    }
}
