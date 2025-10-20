//
//  UserLinks.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct UserLinks: View {
//    @Environment(\.appendToPath) var appendToPath
    
    var body: some View {
        Section {
            HStack {
                LinkButton(
                    icon: "tray.circle.fill",
                    title: "Inbox",
                    iconColor: .blue,
                    
                ) {
//                    appendToPath(InboxDestination())
                }
                
                LinkButton(
                    icon: "bookmark.circle.fill",
                    title: "Saved",
                    iconColor: .green
                ) {
//                    appendToPath(PostFeedType.saved)
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(.init())
        }
    }
}
