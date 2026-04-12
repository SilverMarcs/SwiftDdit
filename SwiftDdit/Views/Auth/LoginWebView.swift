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

    func makeCoordinator() -> Coordinator {
        Coordinator(onLoginSuccess: onLoginSuccess)
    }

    func makeWebView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator

        config.websiteDataStore.httpCookieStore.add(context.coordinator)

        if let url = URL(string: "https://www.reddit.com/login") {
            webView.load(URLRequest(url: url))
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
                if let sessionCookie = cookies.first(where: { $0.name == "reddit_session" }) {
                    self.hasReported = true
                    DispatchQueue.main.async {
                        self.onLoginSuccess(sessionCookie.value)
                    }
                }
            }
        }
    }
}

#if os(macOS)
extension LoginWebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
#else
extension LoginWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
#endif
