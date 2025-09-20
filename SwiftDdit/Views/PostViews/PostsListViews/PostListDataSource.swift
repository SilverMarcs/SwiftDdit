//
//  PostListDataSource.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import Foundation

/// Manages data loading for post lists
@Observable class PostListDataSource {
    private(set) var posts: [Post] = []
    private(set) var isLoading = false
    @ObservationIgnored private(set) var after: String?
    var currentSort: SubListingSortOption = .best
    var searchText = ""
    
    @ObservationIgnored private let feedType: PostFeedType
    
    init(feedType: PostFeedType) {
        self.feedType = feedType
    }
    
    func loadInitialPosts() async {
        guard !isLoading else { return }
        posts = []
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
        posts = []
        after = nil
        
        isLoading = true
        await fetchPosts(isRefresh: true)
        isLoading = false
    }
    
    private func fetchPosts(isRefresh: Bool) async {
        let afterParam = isRefresh ? nil : after
        
        if !searchText.isEmpty {
            let subredditName = feedType.subreddit?.displayName
            let searchResults = await RedditAPI.searchPosts(searchText, subreddit: subredditName, limit: 20)
            guard let searchResults else { return }
            
            posts.append(contentsOf: searchResults)
            // Search doesn't support pagination in the same way, so we reset after
            after = nil
        } else {
            // Regular mode: use normal post fetching
            let sortParam = feedType.canSort ? currentSort : .best
            
            let result = await RedditAPI.fetchPosts(
                for: feedType,
                sort: sortParam,
                after: afterParam,
                limit: 20
            )
            
            guard let (newPosts, newAfter) = result else { return }
            if isRefresh {
                posts = newPosts
            } else {
                let existingIDs = Set(posts.map { $0.id })
                let uniqueNewPosts = newPosts.filter { !existingIDs.contains($0.id) }
                posts.append(contentsOf: uniqueNewPosts)
            }
            after = newAfter
        }
    }
}
