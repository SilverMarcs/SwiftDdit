//
//  PostYouTubeView.swift
//  SwiftDdit
//
//  Created for memory optimization -  YouTube display
//

import SwiftUI
import WebKit

struct PostYouTubeView: View {
    @Environment(\.openURL) var openURL

    @AppStorage("autoplay") private var autoplay = true
    @AppStorage("muteOnPlay") private var muteOnPlay = false
    
    let videoID: String
    let galleryImage: GalleryImage

    @State private var showsPlayer = false
    @State private var isVisible = true
    @State private var page: WebPage

    init(videoID: String, galleryImage: GalleryImage) {
        self.videoID = videoID
        self.galleryImage = galleryImage

        var configuration = WebPage.Configuration()
        configuration.defaultNavigationPreferences.allowsContentJavaScript = true
        #if !os(macOS)
        configuration.mediaPlaybackBehavior = .allowsInlinePlayback
        #endif
        _page = State(initialValue: WebPage(configuration: configuration))
    }

    var body: some View {
        if autoplay || showsPlayer {
            WebView(page)
                .webViewBackForwardNavigationGestures(.disabled)
                .task(id: loadKey) {
                    await loadPlayerHTML()
                }
                .onScrollVisibilityChange(threshold: 0.1) { isVisible in
                    self.isVisible = isVisible

                    if !isVisible {
                        Task { @MainActor in
                            await pausePlayer()
                        }
                    }
                }
                .onDisappear {
                    isVisible = false
                    page.stopLoading()
                    Task { @MainActor in
                        await pausePlayer()
                    }
                }
                .aspectRatio(galleryImage.aspectRatio ?? 16.0 / 9.0, contentMode: .fit)
                .clipShape(.rect(cornerRadius: 12))
        } else {
            YouTubePlaceholderView(galleryImage: galleryImage) {
                showsPlayer = true
            }
        }
    }

    private var loadKey: String {
        "\(videoID)-\(autoplay)-\(muteOnPlay)-\(showsPlayer)"
    }

    @MainActor
    private func loadPlayerHTML() async {
        guard autoplay || showsPlayer else { return }
        guard let baseURL = URL(string: "https://www.youtube-nocookie.com") else { return }

        let html = """
        <!doctype html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
        html, body { margin: 0; padding: 0; background: transparent; height: 100%; }
        #player { position: absolute; inset: 0; width: 100%; height: 100%; }
        .container { position: relative; width: 100%; height: 100%; }
        </style>
        </head>
        <body>
        <div class="container">
        <div id="player"></div>
        </div>
        <script src="https://www.youtube.com/iframe_api"></script>
        <script>
        var player;
        var shouldPlay = false;
        var shouldMute = \(muteOnPlay ? "true" : "false");

        function onYouTubeIframeAPIReady() {
            player = new YT.Player('player', {
                videoId: '\(videoID)',
                playerVars: {
                    playsinline: 1,
                    autoplay: 0,
                    mute: \(muteOnPlay ? 1 : 0),
                    rel: 0,
                    origin: 'https://www.youtube-nocookie.com',
                    enablejsapi: 1
                },
                events: {
                    onReady: onPlayerReady
                }
            });
        }

        function onPlayerReady() {
            if (shouldMute && player && player.mute) {
                player.mute();
            }
            if (shouldPlay && player && player.playVideo) {
                player.playVideo();
            }
        }

        window.__lurkerPlay = function() {
            shouldPlay = true;
            if (player && player.playVideo) {
                if (shouldMute && player.mute) {
                    player.mute();
                }
                player.playVideo();
            }
        };

        window.__lurkerPause = function() {
            shouldPlay = false;
            if (player && player.pauseVideo) {
                player.pauseVideo();
            }
        };
        </script>
        </body>
        </html>
        """

        do {
            for try await _ in page.load(html: html, baseURL: baseURL) {}

            guard !Task.isCancelled, isVisible else {
                await pausePlayer()
                return
            }

            _ = try? await page.callJavaScript(
                "window.__lurkerPlay && window.__lurkerPlay();",
                arguments: [:],
                in: nil,
                contentWorld: nil
            )
        } catch {
            guard !Task.isCancelled, isVisible else {
                await pausePlayer()
                return
            }

            if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
                openURL(url)
            }
        }
    }

    @MainActor
    private func pausePlayer() async {
        _ = try? await page.callJavaScript(
            "window.__lurkerPause && window.__lurkerPause();",
            arguments: [:],
            in: nil,
            contentWorld: nil
        )
    }
}

private struct YouTubePlaceholderView: View {
    let galleryImage: GalleryImage
    let playAction: () -> Void

    var body: some View {
        Button(action: playAction) {
            PostImageView(image: galleryImage)
                .disabled(true)
                .overlay(alignment: .center) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white, .red)
                        .shadow(radius: 3)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Play YouTube video")
    }
}
