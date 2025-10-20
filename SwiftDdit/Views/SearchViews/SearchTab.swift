//
//  SearchTab.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI
import SwiftMediaViewer

struct SearchTab: View {
    @State var path: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            SearchView()
                .navigationDestinations(path: $path)
        }
    }
}
