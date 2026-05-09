//
//  SubredditInfoButton.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import SwiftUI
import SwiftMediaViewer

struct SubredditInfoButton: ToolbarContent {
    let subreddit: Subreddit
    @State private var showingSubredditInfo = false
    @Namespace private var transition
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingSubredditInfo = true
            } label: {
                if let url = URL(string: subreddit.iconURL ?? "") {
                    CachedAsyncImage(url: url, targetSize: 50)
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "info.circle")
                        .tint(subreddit.color ?? .blue)
                }
            }
            .sheet(isPresented: $showingSubredditInfo) {
                SubredditInfoView(subreddit: subreddit)
                    #if !os(macOS)
                    .navigationTransition(.zoom(sourceID: "subreddit-info-\(subreddit.id)", in: transition))
                    #endif
            }
        }
        #if !os(macOS)
        .matchedTransitionSource(id: "subreddit-info-\(subreddit.id)", in: transition)
        #endif
    }
}
