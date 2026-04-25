//
//  ProfileTab.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI
import SwiftMediaViewer

struct ProfileTab: View {
    @State private var navigationManager = NavigationPathManager()

    var body: some View {
        @Bindable var navigationManager = navigationManager

        NavigationStack(path: $navigationManager.path) {
            UserSubredditsView()
                .navigationDestinations()
        }
        .environment(navigationManager)
        .handleURLs(path: $navigationManager.path)
    }
}
