//
//  UserLinks.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct UserLinks: View {
    @Environment(NavigationPathManager.self) var navigationManager

    var body: some View {
        Section {
            HStack {
                LinkButton(
                    icon: "tray.circle.fill",
                    title: "Inbox",
                    iconColor: .blue,
                    
                ) {
                    navigationManager.path.append(InboxDestination())
                }
                
                LinkButton(
                    icon: "bookmark.circle.fill",
                    title: "Saved",
                    iconColor: .green
                ) {
                    navigationManager.path.append(PostFeedType.saved)
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(.init())
        }
    }
}
