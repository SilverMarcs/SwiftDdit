//
//  HomeTab.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 18/06/25.
//

import SwiftUI
import SwiftMediaViewer

struct HomeTab: View {
    @State var path: NavigationPath = NavigationPath()
    @State private var smvPresenter = SMVImagePresenter()
    
    var body: some View {
        NavigationStack(path: $path) {
            PostsList(feedType: .home)
                .navigationDestinations(path: $path, smvPresenter: smvPresenter)
        }
    }
}

#Preview {
    HomeTab()
}
