//
//  CredentialsManager.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 16/06/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CredentialsManager {
    @ObservationIgnored static let shared = CredentialsManager()

    @ObservationIgnored private let keychainManager = KeychainManager.shared
    @ObservationIgnored private let credentialsKey = "reddit_credentials"
    @ObservationIgnored private let activeCredentialKey = "active_reddit_credential_id"
    @ObservationIgnored private let legacyCredentialKey = "reddit_credential"

    var credentials: [RedditCredential] = []
    var activeCredentialId: UUID? = nil
    var isShowingLoginWebView = false
    var authErrorMessage: String?

    var credential: RedditCredential? {
        guard let activeCredentialId = activeCredentialId else {
            return credentials.first
        }
        return credentials.first { $0.id == activeCredentialId }
    }

    private init() {
        loadCredentials()
        if let cred = credential, let cookie = cred.sessionCookie {
            CookieSessionManager.shared.injectCookie(cookie)
        }
    }

    // MARK: - Cookie-Based Login

    func handleLoginCookieReceived(cookie: String) async {
        CookieSessionManager.shared.injectCookie(cookie)

        var newCredential = RedditCredential(sessionCookie: cookie)

        if let userData = await RedditAPI.fetchMe() {
            newCredential.userName = userData.name
            if let iconImg = userData.icon_img, !iconImg.isEmpty {
                newCredential.profilePicture = iconImg
            }
            CookieSessionManager.shared.saveCookie(cookie, forUsername: userData.name)
        }

        saveCredential(newCredential)
        isShowingLoginWebView = false
    }

    func activateSession(for credential: RedditCredential) {
        if let cookie = credential.sessionCookie {
            CookieSessionManager.shared.injectCookie(cookie)
            Task {
                _ = await RedditAPI.fetchMe()
            }
        }
    }

    // MARK: - Credential Management

    func saveCredential(_ newCredential: RedditCredential) {
        if let existingIndex = credentials.firstIndex(where: { $0.id == newCredential.id }) {
            credentials[existingIndex] = newCredential
        } else {
            credentials.append(newCredential)
        }

        if activeCredentialId == nil || credentials.count == 1 {
            activeCredentialId = newCredential.id
        }

        saveToKeychain()
    }

    func deleteCredential(_ credentialToDelete: RedditCredential) {
        if let username = credentialToDelete.userName {
            CookieSessionManager.shared.deleteCookie(forUsername: username)
        }

        credentials.removeAll { $0.id == credentialToDelete.id }

        if activeCredentialId == credentialToDelete.id {
            activeCredentialId = credentials.first?.id
            if let newActive = credential {
                activateSession(for: newActive)
            } else {
                CookieSessionManager.shared.clearInjectedCookies()
                RedditAPI.modhash = nil
            }
        }

        saveToKeychain()
    }

    func setActiveCredential(_ credentialId: UUID) {
        if let cred = credentials.first(where: { $0.id == credentialId }) {
            activeCredentialId = credentialId
            saveActiveCredentialId()
            activateSession(for: cred)
        }
    }

    func deleteAllCredentials() {
        for cred in credentials {
            if let username = cred.userName {
                CookieSessionManager.shared.deleteCookie(forUsername: username)
            }
        }
        CookieSessionManager.shared.clearInjectedCookies()
        RedditAPI.modhash = nil

        credentials.removeAll()
        activeCredentialId = nil
        keychainManager.delete(key: credentialsKey)
        keychainManager.delete(key: activeCredentialKey)
        keychainManager.delete(key: legacyCredentialKey)
    }

    func clearAuthError() {
        authErrorMessage = nil
    }

    private func loadCredentials() {
        if let credentialsData = keychainManager.load(key: credentialsKey),
           let data = credentialsData.data(using: .utf8),
           let loadedCredentials = try? JSONDecoder().decode([RedditCredential].self, from: data) {
            self.credentials = loadedCredentials

            if let activeIdString = keychainManager.load(key: activeCredentialKey),
               let activeId = UUID(uuidString: activeIdString) {
                self.activeCredentialId = activeId
            } else {
                self.activeCredentialId = loadedCredentials.first?.id
            }
            return
        }
    }

    private func saveToKeychain() {
        if !credentials.isEmpty,
           let data = try? JSONEncoder().encode(credentials),
           let jsonString = String(data: data, encoding: .utf8) {
            keychainManager.save(key: credentialsKey, data: jsonString)
        } else {
            keychainManager.delete(key: credentialsKey)
        }

        saveActiveCredentialId()
    }

    private func saveActiveCredentialId() {
        if let activeCredentialId = activeCredentialId {
            keychainManager.save(key: activeCredentialKey, data: activeCredentialId.uuidString)
        } else {
            keychainManager.delete(key: activeCredentialKey)
        }
    }
}
