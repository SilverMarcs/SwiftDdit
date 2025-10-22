//
//  HomeTab.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 18/06/25.
//

import SwiftUI

struct HomeTab: View {
    @State private var navigationManager = NavigationPathManager()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            PostsList(feedType: .home)
                .navigationDestinations()
        }
        .environment(navigationManager)
        .handleURLs(path: $navigationManager.path)
    }
}

#Preview {
    HomeTab()
}
