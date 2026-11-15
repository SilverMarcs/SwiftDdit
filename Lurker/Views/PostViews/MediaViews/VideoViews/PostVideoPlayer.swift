import AVFoundation
import Observation

@MainActor
@Observable
final class PostVideoPlayer {
    private(set) var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    @ObservationIgnored private var preparation: Task<Void, Never>?
    @ObservationIgnored private var preparationID: UUID?
    @ObservationIgnored private var playRequested = false

    func load(videoURL: String, muteOnPlay: Bool, playbackDelay: Duration) async {
        guard !Task.isCancelled, player == nil, preparation == nil else { return }
        guard let url = URL(string: videoURL) else { return }

        let id = UUID()
        preparationID = id
        // Own preparation here so opening fullscreen doesn't cancel an in-flight asset load.
        let preparation = Task { [weak self] in
            defer { self?.finishPreparation(id) }
            // Metadata loading overlaps the existing autoplay delay instead of extending it.
            async let delay: Void = Task.sleep(for: playbackDelay)
            let asset = AVURLAsset(url: url)
            let duration = try? await asset.load(.duration)
            guard !Task.isCancelled, let self, self.preparationID == id else { return }

            let item = AVPlayerItem(asset: asset)
            item.preferredPeakBitRate = 2_000_000
            let player = AVQueuePlayer()
            player.isMuted = muteOnPlay
            if let duration, duration.isNumeric, duration > .zero {
                // The looper supplies its own replicas; don't also enqueue its template item.
                self.looper = AVPlayerLooper(player: player, templateItem: item)
            } else {
                // An unknown/live duration can still play, but cannot safely use the looper.
                player.insert(item, after: nil)
            }
            self.player = player
            if self.playRequested { player.play() }

            do {
                try await delay
                try Task.checkCancellation()
            } catch {
                return
            }
            guard self.preparationID == id, self.player === player else { return }
            player.play()
        }
        self.preparation = preparation
        await preparation.value
    }

    func play() {
        playRequested = true
        player?.play()
    }

    func unload() {
        preparationID = nil
        preparation?.cancel()
        preparation = nil
        playRequested = false
        player?.pause()
        looper?.disableLooping()
        looper = nil
        player?.removeAllItems()
        player = nil
    }

    private func finishPreparation(_ id: UUID) {
        if preparationID == id { preparation = nil }
    }
}
