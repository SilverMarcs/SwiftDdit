//
//  CredentialsView.swift
//  SwiftDdit
//
//  Created by SilverMarcs on 16/06/25.
//

import SwiftUI

struct CredentialsView: View {
    @State private var credentialsManager = CredentialsManager.shared
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

            Section {
                Button {
                    credentialsManager.isShowingLoginWebView = true
                } label: {
                    Label("Add Account", systemImage: "plus.circle")
                }
            } footer: {
                Text("Sign in with your Reddit account using the web login.")
            }
        }
        .navigationTitle("Accounts")
        .toolbarTitleDisplayMode(.inline)
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
        .sheet(isPresented: $credentialsManager.isShowingLoginWebView) {
            NavigationStack {
                LoginWebView { cookie in
                    Task {
                        await credentialsManager.handleLoginCookieReceived(cookie: cookie)
                    }
                }
                .navigationTitle("Sign in to Reddit")
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            credentialsManager.isShowingLoginWebView = false
                        }
                    }
                }
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
}

#Preview {
    NavigationStack {
        CredentialsView()
    }
}
