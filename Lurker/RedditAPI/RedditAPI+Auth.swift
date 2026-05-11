//
//  RedditAPI+Auth.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 22/06/2025.
//

import Foundation

extension RedditAPI {
    /// Wrapper for /user/me/about.json response which includes modhash
    struct MeResponse: Codable {
        let kind: String
        let data: UserData
    }

    /// Fetch current user data from session cookie and store the modhash CSRF token.
    static func fetchMe() async -> UserData? {
        guard let url = buildJSONURL(path: "/user/me/about") else { return nil }
        guard let request = await createAuthenticatedRequest(url: url) else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("[RedditAPI] fetchMe — status=\(status)")
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }

            let meResponse = try JSONDecoder().decode(MeResponse.self, from: data)

            if let modhash = meResponse.data.modhash, !modhash.isEmpty {
                print("[RedditAPI] fetchMe — got modhash=\(modhash.prefix(6))…, user=\(meResponse.data.name)")
                Self.modhash = modhash
            } else {
                print("[RedditAPI] fetchMe — NO modhash in response (data.modhash empty/nil)")
            }

            return meResponse.data
        } catch {
            print("[RedditAPI] fetchMe — error=\(error)")
            return nil
        }
    }

    /// Validate that the current session is still active
    static func validateSession() async -> Bool {
        return await fetchMe() != nil
    }
}
