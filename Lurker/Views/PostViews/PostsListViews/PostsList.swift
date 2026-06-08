//
//  PostsList.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 16/06/25.
//

import SwiftUI

struct PostsList: View {
    @Environment(\.isSearching) var isSearching
    @Environment(NavigationPathManager.self) var navigationManager
    @State private var dataSource: PostListDataSource

    private let feedType: PostFeedType

    init(feedType: PostFeedType) {
        self.feedType = feedType
        self._dataSource = State(initialValue: PostListDataSource(feedType: feedType))
    }

    var body: some View {
        List {
            ForEach(dataSource.posts) { post in
                Button {
                    navigationManager.path.append(post)
                } label: {
                    PostView(post: post)
                        #if !os(macOS)
                        .contentShape(.contextMenuPreview, .rect(cornerRadius: 16))
                        #endif
                }
                .buttonStyle(.plain)
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)
                .listRowInsets(.vertical, 5)
                .listRowInsets(.horizontal, 6)
            }
            .listRowSeparator(.hidden)

            Color.clear
                .frame(height: 1)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .onAppear {
                    if !dataSource.isLoading && dataSource.after != nil && dataSource.searchText.isEmpty {
                        Task {
                            await dataSource.loadMorePosts()
                        }
                    }
                }

            if dataSource.isLoading {
                LoadingIndicator()
                    .id(UUID())
                    .listRowBackground(Color.clear)
            }
        }
        #if os(macOS)
        .scrollIndicators(.hidden)
        #endif
        .listStyle(.plain)
        .navigationTitle(feedType.displayName)
        .toolbarTitleDisplayMode(feedType == .saved ? .inline: .inlineLarge)
        .refreshable {
            await dataSource.refreshPosts()
        }
        .task {
            if dataSource.posts.isEmpty {
                await dataSource.loadInitialPosts()
            }
        }
        .onChange(of: dataSource.currentSort) {
            Task {
                await dataSource.loadInitialPosts()
            }
        }
        .toolbar {
            PostListToolbar(feedType: feedType, selectedSort: $dataSource.currentSort)
        }
        .if(feedType.supportsSearch) { view in
            view
                .searchable(text: $dataSource.searchText, prompt: "Search \(feedType.subreddit?.displayNamePrefixed ?? "")")
                .onSubmit(of: .search) {
                    let query = dataSource.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !query.isEmpty {
                        Task {
                            await dataSource.searchPosts(query)
                        }
                    }
                }
                .onChange(of: dataSource.searchText) {
//                .task(id: dataSource.searchText) {
                    if dataSource.searchText.isEmpty {
                        Task {
                            await dataSource.loadInitialPosts()
                        }
                    }
                }
        }
    }
}
