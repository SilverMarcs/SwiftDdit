import AVKit
import SwiftMediaViewer
import SwiftUI

struct PostVideoPlayerView: View {
    let videoURL: String
    let posterURL: URL?
    let playbackDelay: Duration
    let muteOnPlay: Bool

    @State private var playback = PostVideoPlayer()
    @State private var showsFullScreen = false
    @Namespace private var transition

    var body: some View {
        InlineVideoPlayer(player: playback.player)
            // The player layer stays transparent until its first frame, so the poster shows while it loads.
            .background {
                CachedAsyncImage(url: posterURL, targetSize: 1000) {
                    Color.black
                }
            }
            .allowsHitTesting(false)
            .matchedTransitionSource(id: videoURL, in: transition)
            .overlay {
                Button {
                    playback.play()
                    showsFullScreen = true
                } label: {
                    Color.clear
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open video")
            }
            .task(id: videoURL) {
                guard playback.player == nil else { return }
                await playback.load(
                    videoURL: videoURL,
                    muteOnPlay: muteOnPlay,
                    playbackDelay: playbackDelay
                )
            }
            .onDisappear {
                if !showsFullScreen {
                    playback.unload()
                }
            }
            #if os(macOS)
            .sheet(isPresented: $showsFullScreen) {
                VideoPlayer(player: playback.player)
            }
            #else
            .fullScreenCover(isPresented: $showsFullScreen) {
                VideoPlayer(player: playback.player)
                    .navigationTransition(.zoom(sourceID: videoURL, in: transition))
                    .ignoresSafeArea()
            }
            #endif
    }
}
