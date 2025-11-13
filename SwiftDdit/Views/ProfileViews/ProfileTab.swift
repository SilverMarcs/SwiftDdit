//
//  ProfileTab.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI
import SwiftMediaViewer

struct ProfileTab: View {
    @Bindable var navigationManager = NavigationPathManager()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            UserSubredditsView()
                .navigationDestinations()
        }
        .environment(navigationManager)
        .handleURLs(path: $navigationManager.path)
    }
}
