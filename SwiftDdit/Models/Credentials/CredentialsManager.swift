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
    @ObservationIgnored private let credentialsKey = "reddit_credentials" // Plural for multiple accounts
    @ObservationIgnored private let activeCredentialKey = "active_reddit_credential_id"
    @ObservationIgnored private let legacyCredentialKey = "reddit_credential" // For backward compatibility
    
    // Multiple credentials support
    var credentials: [RedditCredential] = []
    var activeCredentialId: UUID? = nil
    var isWaitingForCallback = false
    var isAuthorizing = false
    var authErrorMessage: String?
    
    // Computed property for backward compatibility
    var credential: RedditCredential? {
        guard let activeCredentialId = activeCredentialId else {
            return credentials.first
        }
        return credentials.first { $0.id == activeCredentialId }
    }
    
    // OAuth state management
    @ObservationIgnored var lastAuthState: String?
    
    private init() {
        loadCredentials()
    }
    
    func saveCredential(_ newCredential: RedditCredential) {
        // Check if updating existing credential
        if let existingIndex = credentials.firstIndex(where: { $0.id == newCredential.id }) {
            credentials[existingIndex] = newCredential
        } else {
            // Add new credential
            credentials.append(newCredential)
        }
        
        // Set as active if it's the first credential or no active credential is set
        if activeCredentialId == nil || credentials.count == 1 {
            activeCredentialId = newCredential.id
        }
        
        saveToKeychain()
    }
    
    func deleteCredential(_ credentialToDelete: RedditCredential) {
        credentials.removeAll { $0.id == credentialToDelete.id }
        
        // If we deleted the active credential, set a new active one
        if activeCredentialId == credentialToDelete.id {
            activeCredentialId = credentials.first?.id
        }
        
        saveToKeychain()
    }
    
    func setActiveCredential(_ credentialId: UUID) {
        if credentials.contains(where: { $0.id == credentialId }) {
            activeCredentialId = credentialId
            saveActiveCredentialId()
        }
    }
    
    func deleteAllCredentials() {
        credentials.removeAll()
        activeCredentialId = nil
        keychainManager.delete(key: credentialsKey)
        keychainManager.delete(key: activeCredentialKey)
        keychainManager.delete(key: legacyCredentialKey)
    }
    
    // Get app credentials from any existing credential for new account setup
    var existingAppCredentials: String? {
        return credentials.first?.apiAppID
    }
    
    private func loadCredentials() {
        // First try to load new format (multiple credentials)
        if let credentialsData = keychainManager.load(key: credentialsKey),
           let data = credentialsData.data(using: .utf8),
           let loadedCredentials = try? JSONDecoder().decode([RedditCredential].self, from: data) {
            self.credentials = loadedCredentials
            
            // Load active credential ID
            if let activeIdString = keychainManager.load(key: activeCredentialKey),
               let activeId = UUID(uuidString: activeIdString) {
                self.activeCredentialId = activeId
            } else {
                // If no active credential set, use the first one
                self.activeCredentialId = loadedCredentials.first?.id
            }
            return
        }
        
        // Fallback to legacy format (single credential) for backward compatibility
        if let credentialData = keychainManager.load(key: legacyCredentialKey),
           let data = credentialData.data(using: .utf8),
           let loadedCredential = try? JSONDecoder().decode(RedditCredential.self, from: data) {
            self.credentials = [loadedCredential]
            self.activeCredentialId = loadedCredential.id
            
            // Migrate to new format
            saveToKeychain()
            keychainManager.delete(key: legacyCredentialKey)
        }
    }
    
    private func saveToKeychain() {
        // Save credentials array
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
    
    // MARK: - OAuth Flow Management
    
    func getAuthorizationCodeURL(_ appID: String) -> URL {
        let response_type: String = "code"
        let state: String = UUID().uuidString
        let redirect_uri: String = RedditAPI.appRedirectURI
        let duration: String = "permanent"
        let scope: String = "identity,edit,flair,history,modconfig,modflair,modlog,modposts,modwiki,mysubreddits,privatemessages,read,report,save,submit,subscribe,vote,wikiedit,wikiread"
        
        lastAuthState = state
        
        let urlString = "https://www.reddit.com/api/v1/authorize.compact?client_id=\(appID.trimmingCharacters(in: .whitespaces))&response_type=\(response_type)&state=\(state)&redirect_uri=\(redirect_uri)&duration=\(duration)&scope=\(scope)"
        
        let finalURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        
        return finalURL
    }

    func prepareAuthorizationURL(appID: String) -> URL? {
        let resolvedAppID = resolveAuthorizationAppID(from: appID)
        guard !resolvedAppID.isEmpty else {
            authErrorMessage = "Please enter your App ID"
            return nil
        }

        keychainManager.saveAppID(resolvedAppID)
        authErrorMessage = nil
        isWaitingForCallback = true
        isAuthorizing = false

        return getAuthorizationCodeURL(resolvedAppID)
    }

    func cancelAuthorization() {
        isWaitingForCallback = false
        isAuthorizing = false
        lastAuthState = nil
    }

    func clearAuthError() {
        authErrorMessage = nil
    }
    
    func getAuthCodeFromURL(_ rawUrl: URL) -> String? {
        
        // Parse URL components directly from the raw URL without conversion
        guard let components = URLComponents(url: rawUrl, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        // Check if this is our expected redirect URL
        // Handle both direct custom scheme and web-based redirects
        let isValidURL = (components.scheme == "swiftddit" && components.host == "auth-success") ||
                        (components.scheme == "swiftddit" && components.path.contains("auth-success"))
        
        guard isValidURL else {
            return nil
        }
        
        // Extract state and code from query parameters
        guard let state = components.queryItems?.first(where: { $0.name == "state" })?.value,
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return nil
        }
        
        // Validate state matches
        guard state == lastAuthState else {
            return nil
        }
        
        return code
    }

    func handleRedirectURL(_ url: URL) async -> RedirectResult {
        guard let authCode = getAuthCodeFromURL(url) else {
            guard isWaitingForCallback else {
                return .ignored
            }

            isWaitingForCallback = false
            lastAuthState = nil
            authErrorMessage = "Authorization was cancelled or failed"
            return .failed
        }

        let resolvedAppID = resolveAuthorizationAppID(from: keychainManager.loadAppID() ?? "")
        guard !resolvedAppID.isEmpty else {
            isWaitingForCallback = false
            lastAuthState = nil
            authErrorMessage = "Please enter your App ID"
            return .failed
        }

        isWaitingForCallback = false
        isAuthorizing = true
        defer {
            isAuthorizing = false
            lastAuthState = nil
        }

        let credential = RedditCredential(apiAppID: resolvedAppID)
        let success = await authorizeCredential(credential, authCode: authCode)

        if success {
            authErrorMessage = nil
            return .success
        }

        authErrorMessage = "Failed to exchange authorization code for access token. Please check your credentials and try again."
        return .failed
    }
    
    func authorizeCredential(_ credential: RedditCredential, authCode: String) async -> Bool {
        guard !credential.apiAppID.isEmpty else {
            return false
        }
        
        // Exchange auth code for tokens
        guard let tokenResponse = await RedditAPI.exchangeAuthCodeForTokens(
            appID: credential.apiAppID,
            authCode: authCode
        ) else {
            return false
        }
        
        var updatedCredential = credential
        let newAccessToken = RedditCredential.AccessToken(
            token: tokenResponse.access_token,
            expiration: tokenResponse.expires_in,
            lastRefresh: Date()
        )
        
        updatedCredential.refreshToken = tokenResponse.refresh_token
        updatedCredential.accessToken = newAccessToken
        
        // Fetch user info
        if let userData = await RedditAPI.fetchMe(with: tokenResponse.access_token) {
            updatedCredential.userName = userData.name
            if let iconImg = userData.icon_img, !iconImg.isEmpty {
                updatedCredential.profilePicture = iconImg
            }
        }
        
        saveCredential(updatedCredential)
        return true
    }
    
    // MARK: - Token Management
    
    func getValidAccessToken() async -> String? {
        guard let activeCredential = credential else { return nil }
        
        let result = await activeCredential.getUpToDateToken()
        
        // Handle credential updates from token refresh
        if let updatedCredential = result.updatedCredential {
            saveCredential(updatedCredential)
        }
        
        return result.token?.token
    }
    
    func getValidAccessToken(for credentialId: UUID) async -> String? {
        guard let targetCredential = credentials.first(where: { $0.id == credentialId }) else { return nil }
        
        let result = await targetCredential.getUpToDateToken()
        
        // Handle credential updates from token refresh
        if let updatedCredential = result.updatedCredential {
            saveCredential(updatedCredential)
        }
        
        return result.token?.token
    }

    private func resolveAuthorizationAppID(from appID: String) -> String {
        if let existingAppID = existingAppCredentials {
            return existingAppID
        }

        return appID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    enum RedirectResult: Equatable {
        case ignored
        case success
        case failed
    }
}
