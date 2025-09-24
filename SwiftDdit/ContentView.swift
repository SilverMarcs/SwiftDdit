//
//  ContentView.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 16/06/25.
//

import SwiftUI

struct ContentView: View {
    @Namespace private var imageNS
    @Namespace private var videoNS
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "doc.text.image") {
                HomeTab()
                    .environment(\.imageNS, imageNS)
                    .environment(\.videoNS, videoNS)
            }
            
            Tab("Profile", systemImage: "person.fill") {
                ProfileTab()
                    .environment(\.imageNS, imageNS)
                    .environment(\.videoNS, videoNS)
            }
            
            #if os(macOS)
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
            #endif
            
            Tab(role: .search) {
                SearchTab()
                    .environment(\.imageNS, imageNS)
                    .environment(\.videoNS, videoNS)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        #if !os(macOS)
        .tabBarMinimizeBehavior(.onScrollDown)
        #endif
        .overlay {
            if CredentialsManager.shared.activeCredentialId == nil {
                ContentUnavailableView(
                    "No Account Connected",
                    systemImage: "person.crop.circle.badge.exclamationmark",
                    description: Text("Go to Profile tab and click Settings > Credentials to add an account first")
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
