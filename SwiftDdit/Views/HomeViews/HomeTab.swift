//
//  HomeTab.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 18/06/25.
//

import SwiftUI

struct HomeTab: View {
    @State var path: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            PostsList(feedType: .home)
                .navigationDestinations(path: $path)
        }
    }
}

#Preview {
    HomeTab()
}
