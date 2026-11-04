//
//  PostListDataSource.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import SwiftUI

@Observable class PostListDataSource {
    /// Every post fetched for this feed, including ones hidden by filters.
    private(set) var fetchedPosts: [Post] = []
    private(set) var isLoading = false
    @ObservationIgnored private(set) var after: String?
    var currentSort: SubListingSortOption
    var searchText = ""

    @ObservationIgnored private let feedType: PostFeedType
    @ObservationIgnored private let filters: FilterManager

    /// How many extra pages to fetch automatically when every post on a page
    /// is hidden by filters, so a heavily filtered feed can't loop forever.
    @ObservationIgnored private let maxExtraFilteredPages = 3

    /// The posts to display. Reading `FilterManager` here means views update
    /// immediately when a subreddit or user is filtered or unfiltered.
    var posts: [Post] {
        fetchedPosts.filter { !filters.shouldHide($0, in: feedType) }
    }

    init(feedType: PostFeedType, filters: FilterManager = .shared) {
        self.feedType = feedType
        self.filters = filters
        self.currentSort = feedType.resolvedInitialSort()
    }

    func loadInitialPosts() async {
        guard !isLoading else { return }
        fetchedPosts = []
        searchText = ""  // Clear search when loading initial posts

        isLoading = true
        await fetchPosts(isRefresh: true)
        isLoading = false
    }

    func loadMorePosts() async {
        guard !isLoading && after != nil else { return }

        isLoading = true
        await fetchPosts(isRefresh: false)
        isLoading = false
    }

    func refreshPosts() async {
        await fetchPosts(isRefresh: true)
    }

    func searchPosts(_ query: String) async {
        guard feedType.supportsSearch else { return }
        guard !isLoading else { return }

        searchText = query.trimmingCharacters(in: .whitespacesAndNewlines)
        fetchedPosts = []
        after = nil

        isLoading = true
        await fetchPosts(isRefresh: true)
        isLoading = false
    }

    private func fetchPosts(isRefresh: Bool) async {
        if !searchText.isEmpty {
            let subredditName = feedType.subreddit?.displayName
            let searchResults = await RedditAPI.searchPosts(searchText, subreddit: subredditName, limit: 20)
            guard let searchResults else { return }

            withAnimation {
                fetchedPosts.append(contentsOf: searchResults)
            }
            // Search doesn't support pagination in the same way, so we reset after
            after = nil
        } else {
            // Regular mode: use normal post fetching
            let sortParam = feedType.canSort ? currentSort : .best
            var afterParam = isRefresh ? nil : after
            var replacesExisting = isRefresh
            var extraPages = 0

            while true {
                let result = await RedditAPI.fetchPosts(
                    for: feedType,
                    sort: sortParam,
                    after: afterParam,
                    limit: 20
                )

                guard let (newPosts, newAfter) = result else { return }
                let addedPosts: [Post]
                if replacesExisting {
                    addedPosts = newPosts
                    withAnimation {
                        fetchedPosts = newPosts
                    }
                    replacesExisting = false
                } else {
                    let existingIDs = Set(fetchedPosts.map { $0.id })
                    addedPosts = newPosts.filter { !existingIDs.contains($0.id) }
                    withAnimation {
                        fetchedPosts.append(contentsOf: addedPosts)
                    }
                }
                after = newAfter

                // If filters hid the whole page, keep going (bounded) so the
                // user isn't left looking at an empty or unchanged list.
                let pageIsFullyFiltered = !addedPosts.isEmpty
                    && addedPosts.allSatisfy { filters.shouldHide($0, in: feedType) }
                guard pageIsFullyFiltered,
                      let newAfter,
                      extraPages < maxExtraFilteredPages else { break }
                extraPages += 1
                afterParam = newAfter
            }
        }
    }
}
