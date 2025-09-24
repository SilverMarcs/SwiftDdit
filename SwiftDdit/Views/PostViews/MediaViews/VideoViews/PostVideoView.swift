import SwiftUI
import AVKit
import SwiftMediaViewer

struct PostVideoView: View {
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = true
    
    let videoURL: String
    let dimensions: CGSize?

    var body: some View {
        SMVVideo(videoURL: videoURL, autoplay: autoplay, muteOnPlay: muteOnPlay)
            .aspectRatio(dimensions != nil ? (dimensions!.width / dimensions!.height) : 16/9, contentMode: .fit)
            .cornerRadius(12)
            .clipped()
    }
}
