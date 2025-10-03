//
//  NavigationDestinations.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI
import SwiftMediaViewer

extension View {
    func commonDestinationModifiers(path: Binding<NavigationPath>, smvPresenter: SMVImagePresenter) -> some View {
        self
            .environment(\.appendToPath, { value in
                path.wrappedValue.append(value)
            })
            .handleURLs(path: path, smvPresenter: smvPresenter)
            .smvImageGateway(presenter: smvPresenter) // ensure the gateway exists above where URLs are handled
    }

    func navigationDestinations(path: Binding<NavigationPath>, smvPresenter: SMVImagePresenter) -> some View {
        self
            .commonDestinationModifiers(path: path, smvPresenter: smvPresenter)
            .navigationDestination(for: PostFeedType.self) { feedType in
                PostsList(feedType: feedType)
                    .commonDestinationModifiers(path: path, smvPresenter: smvPresenter)
            }
            .navigationDestination(for: PostNavigation.self) { postNavigation in
                PostDetailView(postNavigation: postNavigation)
                    .commonDestinationModifiers(path: path, smvPresenter: smvPresenter)
            }
            .navigationDestination(for: Post.self) { post in
                PostDetailView(post: post)
                    .commonDestinationModifiers(path: path, smvPresenter: smvPresenter)
            }
            .navigationDestination(for: Message.self) { message in
                MessageDetailView(message: message)
                    .commonDestinationModifiers(path: path, smvPresenter: smvPresenter)
            }
            .navigationDestination(for: InboxDestination.self) { inbox in
                InboxView()
                    .commonDestinationModifiers(path: path, smvPresenter: smvPresenter)
            }
    }
}

struct InboxDestination: Hashable { }
