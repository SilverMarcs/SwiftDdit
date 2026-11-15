#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
VIDEO_TEST_DIR=${VIDEO_TEST_DIR:-/tmp/lurker-inline-video/UnitTests}
mkdir -p "$VIDEO_TEST_DIR/Sources/VideoPlayback" "$VIDEO_TEST_DIR/Tests/VideoPlaybackTests"
cat > "$VIDEO_TEST_DIR/Package.swift" <<'SWIFT'
// swift-tools-version: 6.2
import PackageDescription
let package = Package(name: "VideoPlayback", platforms: [.macOS(.v26)], targets: [
    .target(name: "VideoPlayback"),
    .testTarget(name: "VideoPlaybackTests", dependencies: ["VideoPlayback"], resources: [.process("Fixtures")])
])
SWIFT
cp Lurker/Views/PostViews/MediaViews/VideoViews/PostVideoPlayer.swift "$VIDEO_TEST_DIR/Sources/VideoPlayback/"
cp Tests/*Tests.swift "$VIDEO_TEST_DIR/Tests/VideoPlaybackTests/"
cp -R Tests/Fixtures "$VIDEO_TEST_DIR/Tests/VideoPlaybackTests/"
swift test --package-path "$VIDEO_TEST_DIR"
