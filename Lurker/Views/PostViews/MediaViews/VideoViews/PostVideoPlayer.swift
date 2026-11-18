import AVFoundation
import Observation

@MainActor
@Observable
final class PostVideoPlayer {
    private(set) var player: AVPlayer?
    @ObservationIgnored private var preparation: Task<Void, Never>?
    @ObservationIgnored private var preparationID: UUID?
    @ObservationIgnored private var looping: Task<Void, Never>?
    @ObservationIgnored private var playRequested = false

    func load(videoURL: String, muteOnPlay: Bool, playbackDelay: Duration) async {
        guard !Task.isCancelled, player == nil, preparation == nil else { return }
        guard let url = URL(string: videoURL) else { return }

        let item = AVPlayerItem(url: url)
        item.preferredPeakBitRate = 2_000_000
        let player = AVPlayer(playerItem: item)
        player.isMuted = muteOnPlay
        // Stay on the finished item so it can rewind, instead of advancing past it.
        player.actionAtItemEnd = .none
        self.player = player
        looping = Self.loop(item, on: player)
        if playRequested { player.play() }

        let id = UUID()
        preparationID = id
        // Own the delay here so opening fullscreen doesn't cancel a pending autoplay.
        let preparation = Task { [weak self] in
            defer { self?.finishPreparation(id) }
            do {
                try await Task.sleep(for: playbackDelay)
            } catch {
                return
            }
            guard let self, self.preparationID == id, self.player === player else { return }
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
        looping?.cancel()
        looping = nil
        playRequested = false
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
    }

    /// Rewinds a single item each time it finishes, which loops it without
    /// the extra item copies `AVPlayerLooper` queues up.
    private static func loop(_ item: AVPlayerItem, on player: AVPlayer) -> Task<Void, Never> {
        Task { [weak player] in
            let ends = NotificationCenter.default.notifications(
                named: AVPlayerItem.didPlayToEndTimeNotification,
                object: item
            )
            for await _ in ends {
                guard let player else { return }
                await player.seek(to: .zero)
                player.play()
            }
        }
    }

    private func finishPreparation(_ id: UUID) {
        if preparationID == id { preparation = nil }
    }
}
