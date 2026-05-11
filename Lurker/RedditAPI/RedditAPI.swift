//
//  RedditAPI.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 16/06/25.
//

import Foundation

enum RedditAPI {
    static let baseURL = "https://www.reddit.com"

    /// CSRF token for authenticated POST requests, fetched after login
    static var modhash: String?

    /// Build a URL for GET endpoints that return JSON (appends .json)
    static func buildJSONURL(path: String) -> URL? {
        let cleanPath = path.hasPrefix("/") ? path : "/\(path)"
        return URL(string: "\(baseURL)\(cleanPath).json")
    }

    /// Create a request with spoofed User-Agent and cookie-based auth.
    /// For POST/DELETE, includes X-Modhash header.
    static internal func createAuthenticatedRequest(url: URL, method: String = "GET") async -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(UserAgentGenerator.randomMobileSafari(), forHTTPHeaderField: "User-Agent")

        if method == "POST" || method == "DELETE" {
            if Self.modhash == nil {
                print("[RedditAPI] \(method) \(url.absoluteString) — modhash missing, fetching…")
                _ = await ensureModhash()
            }
            guard let modhash = Self.modhash else {
                print("[RedditAPI] \(method) \(url.absoluteString) — REJECTED: modhash still nil after fetch")
                return nil
            }
            request.setValue(modhash, forHTTPHeaderField: "X-Modhash")
        }

        return request
    }

    /// Serializes concurrent callers so we only fire one fetchMe() when the modhash is missing.
    @ObservationIgnored private static var modhashFetchTask: Task<String?, Never>?

    static internal func ensureModhash() async -> String? {
        if let existing = Self.modhash { return existing }
        if let inFlight = Self.modhashFetchTask { return await inFlight.value }

        let task = Task<String?, Never> {
            _ = await Self.fetchMe()
            return Self.modhash
        }
        Self.modhashFetchTask = task
        let result = await task.value
        Self.modhashFetchTask = nil
        return result
    }

    static internal func performAuthenticatedRequest<T: Codable>(url: URL, responseType: T.Type) async -> T? {
        guard let request = await createAuthenticatedRequest(url: url) else { return nil }
        return await performRequest(request, responseType: responseType, endpoint: url.absoluteString)
    }

    static internal func performPostRequest(url: URL, parameters: String) async -> Bool {
        guard var request = await createAuthenticatedRequest(url: url, method: "POST") else { return false }
        request.httpBody = parameters.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        return await performSimpleRequest(request)
    }

    static internal func performRequest<T: Codable>(_ request: URLRequest, responseType: T.Type, endpoint: String) async -> T? {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            return nil
        }
    }

    static internal func performSimpleRequest<T: Codable>(_ request: URLRequest, responseType: T.Type) async -> T? {
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            return nil
        }
    }

    static private func performSimpleRequest(_ request: URLRequest) async -> Bool {
        let urlStr = request.url?.absoluteString ?? "?"
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            let bodyPreview = String(data: data, encoding: .utf8)?.prefix(200) ?? ""
            print("[RedditAPI] POST \(urlStr) — status=\(status), body=\(bodyPreview)")
            return status == 200
        } catch {
            print("[RedditAPI] POST \(urlStr) — error=\(error)")
            return false
        }
    }

    /// Perform a GET request without requiring authentication (for unauthenticated .json endpoints)
    static internal func performUnauthenticatedRequest<T: Codable>(url: URL, responseType: T.Type) async -> T? {
        var request = URLRequest(url: url)
        request.setValue(UserAgentGenerator.randomMobileSafari(), forHTTPHeaderField: "User-Agent")
        return await performRequest(request, responseType: responseType, endpoint: url.absoluteString)
    }
}
