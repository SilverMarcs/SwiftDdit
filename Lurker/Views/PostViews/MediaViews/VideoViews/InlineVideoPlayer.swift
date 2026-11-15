import AVFoundation
import SwiftUI

/// A stable video surface, mounted even while its player is still being prepared.
struct InlineVideoPlayer {
    let player: AVPlayer?
}

#if os(macOS)
extension InlineVideoPlayer: NSViewRepresentable {
    func makeNSView(context: Context) -> VideoPlayerLayerView {
        let view = VideoPlayerLayerView()
        view.wantsLayer = true
        view.playerLayer?.videoGravity = .resizeAspect
        view.playerLayer?.player = player
        return view
    }

    func updateNSView(_ view: VideoPlayerLayerView, context: Context) {
        if view.playerLayer?.player !== player { view.playerLayer?.player = player }
    }

    static func dismantleNSView(_ view: VideoPlayerLayerView, coordinator: ()) {
        view.playerLayer?.player = nil
    }
}
#else
extension InlineVideoPlayer: UIViewRepresentable {
    func makeUIView(context: Context) -> VideoPlayerLayerView {
        let view = VideoPlayerLayerView()
        view.playerLayer?.videoGravity = .resizeAspect
        view.playerLayer?.player = player
        return view
    }

    func updateUIView(_ view: VideoPlayerLayerView, context: Context) {
        if view.playerLayer?.player !== player { view.playerLayer?.player = player }
    }

    static func dismantleUIView(_ view: VideoPlayerLayerView, coordinator: ()) {
        view.playerLayer?.player = nil
    }
}
#endif
