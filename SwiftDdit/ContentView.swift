//
//  ContentView.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 16/06/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(SettingsNavigationCoordinator.self) private var settingsNavigation
    @State private var credentialsManager = CredentialsManager.shared
    @State private var selectedTab: AppTab = .home
    #if os(macOS)
    @Environment(\.openSettings) private var openSettings
    #endif

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "doc.text.image", value: .home) {
                HomeTab()
            }
            
            Tab("Profile", systemImage: "person.fill", value: .profile) {
                ProfileTab()
            }

            Tab(value: .search, role: .search) {
                SearchTab()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewSearchActivation(.searchTabSelection)
        .overlay {
            if credentialsManager.activeCredentialId == nil {
                ContentUnavailableView(
                    "No Account Connected",
                    systemImage: "person.crop.circle.badge.exclamationmark",
                    description: Text("Go to Profile tab and click Settings > Credentials to add an account first")
                )
            }
        }
        .onOpenURL { url in
            Task {
                await handleRedirectURL(url)
            }
        }
    }

    @MainActor
    private func handleRedirectURL(_ url: URL) async {
        let result = await credentialsManager.handleRedirectURL(url)
        guard result != .ignored else { return }

        #if os(macOS)
        openSettings()
        #else
        selectedTab = .profile
        settingsNavigation.presentSettings(open: .accounts)
        #endif
    }
}

#Preview {
    ContentView()
        .environment(SettingsNavigationCoordinator())
}
