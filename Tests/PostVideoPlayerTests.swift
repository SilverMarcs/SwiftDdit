import AVFoundation
import Foundation
import Testing
@testable import VideoPlayback

@Suite @MainActor
struct PostVideoPlayerTests {
    @Test func cancelledLoadDoesNotCreateAPlayer() async throws {
        let url = try #require(Bundle.module.url(forResource: "clip", withExtension: "mp4"))
        let model = PostVideoPlayer()
        let load = Task {
            await Task.yield()
            await model.load(videoURL: url.absoluteString, muteOnPlay: true, playbackDelay: .zero)
        }
        load.cancel()
        await load.value
        #expect(model.player == nil)
        model.unload()
    }

    @Test func autoplayAdvancesWithoutAThumbnail() async throws {
        let url = try #require(Bundle.module.url(forResource: "clip", withExtension: "mp4"))
        let model = PostVideoPlayer()
        defer { model.unload() }
        await model.load(videoURL: url.absoluteString, muteOnPlay: true, playbackDelay: .zero)
        let player = try #require(model.player)
        #expect(player.isMuted)
        try await waitUntil { player.currentTime().seconds > 0.1 }
    }

    @Test func manualPlayBypassesThePendingDelay() async throws {
        let url = try #require(Bundle.module.url(forResource: "clip", withExtension: "mp4"))
        let model = PostVideoPlayer()
        let load = Task { await model.load(videoURL: url.absoluteString, muteOnPlay: true, playbackDelay: .seconds(60)) }
        defer { model.unload(); load.cancel() }
        try await waitUntil { model.player != nil }
        let player = try #require(model.player)
        #expect(player.rate == 0)
        model.play()
        try await waitUntil { player.currentTime().seconds > 0.1 }
        model.unload()
        await load.value
        #expect(model.player == nil)
        #expect(player.items().isEmpty)
    }

    @Test func unloadCancelsPreparationAndAllowsAnotherVideo() async throws {
        let url = try #require(Bundle.module.url(forResource: "clip", withExtension: "mp4"))
        let model = PostVideoPlayer()
        let firstLoad = Task { await model.load(videoURL: url.absoluteString, muteOnPlay: true, playbackDelay: .seconds(60)) }
        defer { model.unload(); firstLoad.cancel() }
        try await waitUntil { model.player != nil }
        let oldPlayer = try #require(model.player)
        model.unload()
        await firstLoad.value
        await model.load(videoURL: url.absoluteString, muteOnPlay: false, playbackDelay: .zero)
        let newPlayer = try #require(model.player)
        #expect(newPlayer !== oldPlayer)
        #expect(!newPlayer.isMuted)
        #expect(oldPlayer.items().isEmpty)
    }

    private func waitUntil(_ condition: () -> Bool) async throws {
        let deadline = ContinuousClock.now + .seconds(5)
        while !condition(), ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(20))
        }
        #expect(condition())
    }
}
