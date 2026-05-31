//
//  ContentView.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 16/06/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "doc.text.image", value: .home) {
                HomeTab()
            }

            Tab("Profile", systemImage: "person.fill", value: .profile) {
                ProfileTab()
            }
            
            #if os(macOS)
            Tab("Settings", systemImage: "gear", value: .profile) {
                ProfileTab()
            }
            #endif

            Tab(value: .search, role: .search) {
                SearchTab()
            }
        }
        #if !os(macOS)
        .tabViewStyle(.sidebarAdaptable)
        #endif
        .tabViewSearchActivation(.searchTabSelection)
    }
}

#Preview {
    ContentView()
}
