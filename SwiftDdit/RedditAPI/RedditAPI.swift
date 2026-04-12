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
        guard CredentialsManager.shared.credential?.sessionCookie != nil else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(UserAgentGenerator.randomMobileSafari(), forHTTPHeaderField: "User-Agent")

        if method == "POST" || method == "DELETE" {
            guard let modhash = Self.modhash else {
                return nil
            }
            request.setValue(modhash, forHTTPHeaderField: "X-Modhash")
        }

        return request
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
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
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
