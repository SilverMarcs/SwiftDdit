//
//  PostGIFView.swift
//  SwiftDdit
//
//  Created for memory optimization -  GIF display
//

import SwiftUI
import WebKit
import SwiftMediaViewer

struct PostGIFView: View {
    @AppStorage("autoplay") var autoplay: Bool = true
    
    let galleryImage: GalleryImage
    @State private var showGIF = false
    @State private var lastLoadedURL: URL?
    @State private var page: WebPage?
    @State private var isWebViewReady = false
    
    var body: some View {
        ZStack {
            // Still image (thumbnail)
            CachedAsyncImage(url: URL(string: galleryImage.url), targetSize: 450)
                .opacity(autoplay || showGIF ? 0 : 1)
                .overlay {
                    if !(autoplay || showGIF) {
                        Image(systemName: "play.fill")
                            .imageScale(.large)
                            .padding()
                            .glassEffect(in: .circle)
                            .foregroundStyle(.white)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if !(autoplay || showGIF) {
                        Text("GIF")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.black.secondary, in: .rect(cornerRadius: 5))
                            .padding(10)
                    }
                }
                .onTapGesture {
                    showGIF = true
                }

            // WebView on top, but only visible when ready
            if let page {
                WebView(page)
                    .webViewBackForwardNavigationGestures(.disabled)
                    .webViewMagnificationGestures(.disabled)
                    .webViewTextSelection(.disabled)
                    .webViewContentBackground(.hidden)
                    .opacity((autoplay || showGIF) && isWebViewReady ? 1 : 0)
            } else {
                if autoplay || showGIF {
                    ProgressView()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .aspectRatio(galleryImage.aspectRatio, contentMode: .fit)
        .task {
            if let url = galleryImage.urlObject {
                await loadPageIfNeeded(for: url)
            }
        }
    }
    
    private func loadPageIfNeeded(for url: URL, forceReload: Bool = false) async {
        guard forceReload || lastLoadedURL != url else { return }
        
        var configuration = WebPage.Configuration()
        configuration.defaultNavigationPreferences.preferredContentMode = .mobile
        let page = WebPage(configuration: configuration)

        isWebViewReady = false

        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
        <style>
        html, body { margin: 0; padding: 0; background: transparent; }
        body { display: flex; align-items: center; justify-content: center; }
        img { width: 100%; height: auto; display: block; }
        </style>
        </head>
        <body>
        <img src="\(url.absoluteString)" alt="gif" />
        </body>
        </html>
        """

        page.load(html: html, baseURL: url.deletingLastPathComponent())

        await MainActor.run {
            self.page = page
            self.lastLoadedURL = url
            self.isWebViewReady = true
        }
    }
}
