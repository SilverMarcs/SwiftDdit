//
//  CookieSessionManager.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 13/04/2026.
//

import Foundation
import WebKit

final class CookieSessionManager {
    static let shared = CookieSessionManager()
    private let keychain = KeychainManager.shared
    private init() {}

    func saveCookie(_ cookieValue: String, forUsername username: String) {
        keychain.save(key: "reddit_session_\(username)", data: cookieValue)
    }

    func loadCookie(forUsername username: String) -> String? {
        keychain.load(key: "reddit_session_\(username)")
    }

    func deleteCookie(forUsername username: String) {
        keychain.delete(key: "reddit_session_\(username)")
    }

    func injectCookie(_ cookieValue: String) {
        clearInjectedCookies()
        let properties: [HTTPCookiePropertyKey: Any] = [
            .domain: ".reddit.com", .path: "/", .name: "reddit_session",
            .value: cookieValue, .secure: "TRUE",
            .expires: Date(timeIntervalSinceNow: 86400 * 365 * 10)
        ]
        if let cookie = HTTPCookie(properties: properties) {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
    }

    func clearInjectedCookies() {
        guard let url = URL(string: "https://www.reddit.com"),
              let cookies = HTTPCookieStorage.shared.cookies(for: url) else { return }
        for cookie in cookies where cookie.name == "reddit_session" {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
    }

    /// Clear cookies from BOTH HTTPCookieStorage AND WKWebsiteDataStore.
    /// Must be called before showing the login WebView to prevent auto-detection
    /// of an existing session. Mirrors Hydra's clearSessionCookies().
    func clearAllCookies() async {
        // Clear HTTPCookieStorage
        clearInjectedCookies()

        // Clear WKWebsiteDataStore (the WebView's cookie jar)
        let dataStore = WKWebsiteDataStore.default()
        let cookies = await dataStore.httpCookieStore.allCookies()
        for cookie in cookies where cookie.name == "reddit_session" {
            await dataStore.httpCookieStore.deleteCookie(cookie)
        }
    }
}
