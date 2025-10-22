//
//  SearchTab.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI
import SwiftMediaViewer

struct SearchTab: View {
    @State private var navigationManager = NavigationPathManager()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            SearchView()
                .navigationDestinations()
        }
        .environment(navigationManager)
        .handleURLs(path: $navigationManager.path)
    }
}
