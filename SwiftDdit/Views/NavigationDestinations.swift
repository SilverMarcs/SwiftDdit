//
//  NavigationDestinations.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

extension View {
    func navigationDestinations() -> some View {
        self
            .navigationDestination(for: PostFeedType.self) { feedType in
                PostsList(feedType: feedType)
            }
            .navigationDestination(for: PostNavigation.self) { postNavigation in
                PostDetailView(postNavigation: postNavigation)
            }
            .navigationDestination(for: Post.self) { post in
                PostDetailView(post: post)
            }
            .navigationDestination(for: Message.self) { message in
                MessageDetailView(message: message)
            }
            .navigationDestination(for: InboxDestination.self) { inbox in
                InboxView()
            }
            .navigationDestination(for: SettingsDestination.self) { _ in
                SettingsView()
            }
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .accounts:
                    CredentialsView()
                case .appIcon:
                    #if os(iOS) || os(tvOS) || os(visionOS)
                    AppIconPicker()
                    #else
                    EmptyView()
                    #endif
                }
            }
    }
}

struct InboxDestination: Hashable { }
