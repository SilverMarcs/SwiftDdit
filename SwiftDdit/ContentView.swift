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

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "doc.text.image", value: .home) {
                HomeTab()
            }
            
            Tab("Profile", systemImage: "person.fill", value: .profile) {
                ProfileTab()
                    .overlay {
                        if credentialsManager.activeCredentialId == nil {
                            ContentUnavailableView(
                                "No Account Connected",
                                systemImage: "person.crop.circle.badge.exclamationmark",
                                description: Text("Go to Profile tab and click Settings > Credentials to add an account first")
                            )
                        }
                    }
            }

            Tab(value: .search, role: .search) {
                SearchTab()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewSearchActivation(.searchTabSelection)
    }
}

#Preview {
    ContentView()
        .environment(SettingsNavigationCoordinator())
}
