//
//  PostDetail.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI

struct PostDetailView: View {    
    @State private var dataSource: PostDetailDataSource
    
    init(post: Post) {
        self._dataSource = State(initialValue: PostDetailDataSource(post: post))
    }
    
    init(postNavigation: PostNavigation) {
        self._dataSource = State(initialValue: PostDetailDataSource(postNavigation: postNavigation))
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if let post = dataSource.post {
                    PostView(
                        post: post,
                        isCompact: false,
                        addOptimisticTopLevelComment: dataSource.addOptimisticTopLevelComment
                    )
                    
                    Divider()
                }
                
                if dataSource.isLoading {
                    LoadingIndicator()
                        .id(UUID())
                        .padding()
                    
                } else if !dataSource.visibleComments.isEmpty {
                    Text("Comments")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.vertical, 10)

                    ForEach(dataSource.visibleComments) { comment in
                        VStack(spacing: 8) {
                            if comment.depth == 0 && comment.id != dataSource.visibleComments.first?.id {
                                Rectangle()
                                    .fill(.background.secondary)
                                    .frame(height: 6)
                                    .padding(.horizontal, -15)
                            } else if comment.id != dataSource.visibleComments.first?.id {
                                Divider()
                            }
                            
                            CommentView(
                                comment: comment,
                                isCollapsed: dataSource.collapsedCommentIds.contains(comment.id)
                            ) { commentId in
                                dataSource.toggleCommentCollapse(commentId)
                            }
                            .environment(\.addOptimisticComment, dataSource.addOptimisticComment)
                        }
                    }
                }
            }
            #if os(macOS)
            .frame(maxWidth: 600, alignment: .center)
            .scenePadding(.vertical)
            #endif
            .scenePadding(.horizontal)
            .scenePadding(.bottom)
            .scrollTargetLayout()
        }
        .scrollPosition($dataSource.scrollPosition)
        .task {
            if dataSource.allComments.isEmpty {
                await dataSource.loadComments()
            }
        }
        .onChange(of: dataSource.sortOption) {
            Task {
                await dataSource.loadComments()
            }
        }
        .refreshable {
            await dataSource.loadComments(resetPost: true)
        }
        .navigationTitle(dataSource.post?.subreddit.displayNamePrefixed ?? "Post")
        .navigationSubtitle(dataSource.post?.formattedNumComments.appending(" comments") ?? "Loading...")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(CommentSortOption.allCases, id: \.self) { option in
                        Button {
                            dataSource.sortOption = option
                        } label: {
                            Label(option.displayName, systemImage: option.iconName)
                                .tag(option)
                        }
                    }
                } label: {
                    Label("Sort by", systemImage: dataSource.sortOption.iconName)
                        .labelStyle(.iconOnly)
                }
                .tint(.accent)
            }
        }
    }
}
