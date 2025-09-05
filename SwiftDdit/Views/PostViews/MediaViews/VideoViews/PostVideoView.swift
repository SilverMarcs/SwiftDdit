import SwiftUI
import AVKit

struct PostVideoView: View {
    @Environment(\.videoNS) private var videoNS
    @Namespace private var fallbackNS
    
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = true
    
    let videoURL: String?
    let thumbnailURL: String?
    let dimensions: CGSize?

    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper?

    var body: some View {
        VideoPlayer(player: player)
            .aspectRatio(dimensions != nil ? (dimensions!.width / dimensions!.height) : 16/9, contentMode: .fit)
            .matchedGeometryEffect(id: videoURL ?? "videoPlayer", in: videoNS ?? fallbackNS)
//            .transition(.scale(scale: 1))
            .cornerRadius(12)
            .clipped()
            .overlay(
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        VideoOverlayViewModel.shared.present(player: player, videoURL: videoURL)
                    }
            )
            .task {
                await setupPlayer()
            }
            .onDisappear {
                cleanupPlayer()
            }
    }
    
    private func setupPlayer() async {
        guard let videoURL = videoURL,
              let url = URL(string: videoURL),
              player == nil else { return }
        
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredPeakBitRate = 2_000_000
        
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.isMuted = muteOnPlay
        
        // Use AVPlayerLooper instead of notification
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        player = queuePlayer
        
        if autoplay {
            queuePlayer.play()
        }
    }
    
    private func cleanupPlayer() {
        player?.pause()
        playerLooper?.disableLooping()
        playerLooper = nil
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
}


//import SwiftUI
//import AVKit
//
//struct PostVideoView: View {
//    @StateObject private var playerHolder = PlayerHolder()
//    
//    let videoURL: String?
//    let dimensions: CGSize?
//    
//    var body: some View {
//        VStack {
//            if let player = playerHolder.player {
//                AVPlayerInlineView(player: player, controller: playerHolder.controller)
//                    .aspectRatio(dimensions != nil ? (dimensions!.width / dimensions!.height) : 16/9, contentMode: .fit)
//                    .cornerRadius(12)
//                    .onAppear {
//                        player.play()
//                    }
//            } else {
//                Color.black
//                    .aspectRatio(dimensions != nil ? (dimensions!.width / dimensions!.height) : 16/9, contentMode: .fit)
//                    .task {
//                        await setupPlayer()
//                    }
//            }
//        }
//    }
//    
//    private func setupPlayer() async {
//        guard let videoURL = videoURL,
//              let url = URL(string: videoURL),
//              playerHolder.player == nil else { return }
//        
//        let asset = AVURLAsset(url: url)
//        let playerItem = AVPlayerItem(asset: asset)
//        playerItem.preferredPeakBitRate = 2_000_000
//        
//        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
//        queuePlayer.isMuted = true
//        
//        playerHolder.player = queuePlayer
//        playerHolder.controller.player = queuePlayer
//        playerHolder.controller.showsPlaybackControls = true
//        playerHolder.controller.exitsFullScreenWhenPlaybackEnds = false
//    }
//}
//
//import Combine
//
//final class PlayerHolder: ObservableObject {
//    @Published var player: AVQueuePlayer?
//    let controller = AVPlayerViewController()
//}
//
//// Inline SwiftUI wrapper
//struct AVPlayerInlineView: UIViewControllerRepresentable {
//    let player: AVPlayer
//    let controller: AVPlayerViewController
//    
//    func makeUIViewController(context: Context) -> AVPlayerViewController {
//        controller
//    }
//    
//    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
//}
//
//// Fullscreen wrapper
//struct AVPlayerFullscreenView: UIViewControllerRepresentable {
//    let player: AVPlayer
//    
//    func makeUIViewController(context: Context) -> AVPlayerViewController {
//        let vc = AVPlayerViewController()
//        vc.player = player
//        vc.showsPlaybackControls = true
//        return vc
//    }
//    
//    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
//}
