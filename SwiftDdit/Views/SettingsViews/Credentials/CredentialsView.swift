//
//  CredentialsView.swift
//  SwiftDdit
//
//  Created by SilverMarcs on 16/06/25.
//

import SwiftUI

struct CredentialsView: View {
    @State private var credentialsManager = CredentialsManager.shared
    @State private var appID = KeychainManager.shared.loadAppID() ?? ""
    @State private var showingDeleteAlert = false
    @State private var credentialToDelete: RedditCredential?
    
    private var hasAnyCredentials: Bool {
        !credentialsManager.credentials.isEmpty
    }
    
    var body: some View {
        List {
            if hasAnyCredentials {
                Section("Reddit Accounts") {
                    ForEach(credentialsManager.credentials) { credential in
                        AccountRowView(credential: credential)
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            credentialToDelete = credentialsManager.credentials[index]
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            
//            if !hasAnyCredentials {
                Section("Step 1: Get Your App ID") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Go to Reddit's app preferences")
                        Text("2. Create a new app (select 'installed app')")
                        Text("3. Set the redirect URI to the following url:")
                        
                        HStack {
                            Text("swiftddit://auth-success")
                                .monospaced()
                            Spacer()
                            Button {
                                #if os(macOS)
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString("swiftddit://auth-success", forType: .string)
                                #else
                                UIPasteboard.general.string = "swiftddit://auth-success"
                                #endif
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                            }
                            .controlSize(.small)
                        }
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.background.tertiary)
                        }
                        
                        Text("4. Paste the App ID below")
                    }
                    .focusEffectDisabled()
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    Link(destination: URL(string: "https://www.reddit.com/prefs/apps")!) {
                        Label("Open Reddit App Settings", systemImage: "safari")
                    }
                    .environment(\.openURL, OpenURLAction { url in
                        return .systemAction
                    })
                }
                Section("Step 2: Enter Your App ID") {
                    TextField("Enter your Reddit app ID", text: $appID)
                        .onChange(of: appID) { _, newValue in
                            KeychainManager.shared.saveAppID(newValue)
                        }
                }
            
                Section("Step 3: Add Account") {
                    Text("Click Plus button on top right and complete the auth flow in reddit website")
                }
//            }
        }
        .navigationTitle("Accounts")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if credentialsManager.isAuthorizing || credentialsManager.isWaitingForCallback {
                    Button("Cancel") {
                        credentialsManager.cancelAuthorization()
                    }
                } else {
                    Button(action: authorizeCredential) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .alert("Error", isPresented: authErrorBinding) {
            Button("OK") {
                credentialsManager.clearAuthError()
            }
        } message: {
            Text(credentialsManager.authErrorMessage ?? "Unknown error")
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showingDeleteAlert = false
                credentialToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let credential = credentialToDelete {
                    credentialsManager.deleteCredential(credential)
                }
                showingDeleteAlert = false
                credentialToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this account? This action cannot be undone.")
        }
        .onAppear {
            // Pre-populate app credentials if we have existing accounts
            if let existingAppID = credentialsManager.existingAppCredentials {
                appID = existingAppID
            } else {
                appID = KeychainManager.shared.loadAppID() ?? ""
            }
        }
    }

    private var authErrorBinding: Binding<Bool> {
        Binding(
            get: { credentialsManager.authErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    credentialsManager.clearAuthError()
                }
            }
        )
    }

    private func authorizeCredential() {
        guard let authURL = credentialsManager.prepareAuthorizationURL(appID: appID) else {
            return
        }

        #if os(macOS)
        NSWorkspace.shared.open(authURL)
        #else
        UIApplication.shared.open(authURL)
        #endif
    }
}

#Preview {
    NavigationStack {
        CredentialsView()
    }
}
