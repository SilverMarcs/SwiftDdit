//
//  LoginWebView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 13/04/2026.
//

import SwiftUI
import WebKit

struct LoginWebView {
    let onLoginSuccess: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onLoginSuccess: onLoginSuccess) }

    func makeWebView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator

        // Wipe all Reddit website data (cookies, localStorage, IndexedDB, service workers,
        // caches) BEFORE loading. Cookie-only scrub isn't sufficient across relaunches —
        // Reddit's JS uses localStorage / service workers to silently re-auth and reissue
        // a reddit_session for the previous user, which the observer would then capture.
        let dataStore = config.websiteDataStore
        let allTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        dataStore.fetchDataRecords(ofTypes: allTypes) { records in
            let redditRecords = records.filter { $0.displayName.contains("reddit") }
            dataStore.removeData(ofTypes: allTypes, for: redditRecords) {
                // Only start observing AFTER clearing, to avoid false triggers
                dataStore.httpCookieStore.add(context.coordinator)
                if let url = URL(string: "https://www.reddit.com/login") {
                    webView.load(URLRequest(url: url))
                }
            }
        }

        return webView
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKHTTPCookieStoreObserver {
        let onLoginSuccess: (String) -> Void
        private var hasReported = false

        init(onLoginSuccess: @escaping (String) -> Void) {
            self.onLoginSuccess = onLoginSuccess
        }

        func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
            guard !hasReported else { return }
            cookieStore.getAllCookies { [weak self] cookies in
                guard let self, !self.hasReported else { return }
                if let session = cookies.first(where: { $0.name == "reddit_session" }) {
                    self.hasReported = true
                    DispatchQueue.main.async { self.onLoginSuccess(session.value) }
                }
            }
        }
    }
}

#if os(macOS)
extension LoginWebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView { makeWebView(context: context) }
    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
#else
extension LoginWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView { makeWebView(context: context) }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
#endif
