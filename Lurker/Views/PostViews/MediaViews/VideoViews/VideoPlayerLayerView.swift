import AVFoundation

#if os(macOS)
import AppKit

final class VideoPlayerLayerView: NSView {
    var playerLayer: AVPlayerLayer? { layer as? AVPlayerLayer }

    override func makeBackingLayer() -> CALayer {
        AVPlayerLayer()
    }
}
#else
import UIKit

final class VideoPlayerLayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer? { layer as? AVPlayerLayer }
}
#endif
