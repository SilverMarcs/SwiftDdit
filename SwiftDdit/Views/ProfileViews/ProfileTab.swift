//
//  ProfileView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI
import SwiftMediaViewer

struct ProfileTab: View {
    @State var path: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            UserSubredditsView()
                .navigationDestinations(path: $path)
        }
    }
}
