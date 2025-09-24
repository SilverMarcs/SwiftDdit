//
//  NavigationDestinations.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

extension View {
    func commonDestinationModifiers(path: Binding<NavigationPath>) -> some View {
        self
            .environment(\.appendToPath, { value in
                path.wrappedValue.append(value)
            })
            .handleURLs(path: path)
    }
    
    func navigationDestinations(path: Binding<NavigationPath>) -> some View {
        self
            .commonDestinationModifiers(path: path)
            .navigationDestination(for: PostFeedType.self) { feedType in
                PostsList(feedType: feedType)
                    .commonDestinationModifiers(path: path)
            }
            .navigationDestination(for: PostNavigation.self) { postNavigation in
                PostDetailView(postNavigation: postNavigation)
                    .commonDestinationModifiers(path: path)
            }
            .navigationDestination(for: Post.self) { post in
                PostDetailView(post: post)
                    .commonDestinationModifiers(path: path)
            }
            .navigationDestination(for: Message.self) { message in
                MessageDetailView(message: message)
                    .commonDestinationModifiers(path: path)
            }
            .navigationDestination(for: InboxDestination.self) { inbox in
                InboxView()
                    .commonDestinationModifiers(path: path)
            }
    }
}

struct InboxDestination: Hashable { }
