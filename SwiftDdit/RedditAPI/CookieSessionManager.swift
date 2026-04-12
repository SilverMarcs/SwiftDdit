//
//  CookieSessionManager.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 13/04/2026.
//

import Foundation

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
        if let existingCookies = HTTPCookieStorage.shared.cookies(for: URL(string: "https://www.reddit.com")!) {
            for cookie in existingCookies where cookie.name == "reddit_session" {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
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
        if let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: "https://www.reddit.com")!) {
            for cookie in cookies where cookie.name == "reddit_session" {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
}
