//
//  PostView.swift
//  SwiftDdit
//
//  Created for memory optimization
//

import SwiftUI

struct PostView: View {
    let post: Post
    var isCompact: Bool = true
    var addOptimisticTopLevelComment: ((String, String) -> Void)? = nil

    @State private var isSaved: Bool
    @State private var showTextSelection: Bool = false
    @State private var showCommentSheet = false
    @Namespace private var transition

    @Environment(NavigationPathManager.self) var navigationManager

    init(post: Post, isCompact: Bool = true, addOptimisticTopLevelComment: ((String, String) -> Void)? = nil) {
        self.post = post
        self.isCompact = isCompact
        self.addOptimisticTopLevelComment = addOptimisticTopLevelComment
        self._isSaved = State(initialValue: post.saved)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.system(size: 19)) // title3 is fine
                .fontWeight(.semibold)
                .lineLimit(isCompact ? 3 : nil)
                .multilineTextAlignment(.leading)

            // Flair if available
            if let flair = post.linkFlairText, !flair.isEmpty {
                Text(flair)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(post.flairBackgroundColor)
                    .foregroundStyle(post.flairTextColor)
                    .cornerRadius(4)
            }

          // ADD NSFW BADGE

            if !post.selftext.isEmpty {
                Text(LocalizedStringKey(post.selftext))
                    .font(isCompact ? .callout : .default)
                    .foregroundStyle(isCompact ? .secondary : .primary)
                    .opacity(isCompact ? 1 : 0.9)
                    .lineLimit(isCompact ? 3 : nil)
        }

          if post.mediaType.hasMedia {
              PostMediaView(mediaType: post.mediaType)
          }

          Divider()

          HStack {
              SubredditButton(subreddit: post.subreddit, type: .icon(iconUrl: post.subreddit.iconURL ?? ""))

              VStack(alignment: .leading, spacing: 3) {
                  SubredditButton(subreddit: post.subreddit, type: .text)

                  HStack(spacing: 10) {
                        HStack(spacing: 4) {
                          Image(systemName: "bubble.left")

                            Text(post.formattedNumComments)
                         }

                         HStack(spacing: 4) {
                             Image(systemName: "clock")

                             Text(post.timeAgo)
                         }
                   }
                   .font(.caption)
                   .fontWeight(.semibold)
                   .foregroundStyle(.secondary)
               }

               Spacer()

               GlassEffectContainer {
                   if !isCompact {
                       Button {
                           showCommentSheet = true
                       } label: {
                           Image(systemName: "arrowshape.turn.up.backward.fill")
                               .font(.headline)
                               .foregroundStyle(.accent)
                               .padding(3.5)
                       }
                       .matchedTransitionSource(id: "reply-button", in: transition)
                       .buttonStyle(.glass)
                       .buttonBorderShape(.circle)
                   } else {
                       toggleSaveButton
                           .font(.headline)
                           .labelStyle(.iconOnly)
                           .buttonStyle(.glass)
                           .controlSize(.regular)
                           .buttonBorderShape(.circle)
                   }

                   PostActionsView(post: post)
               }
             }
         }
         .padding(.horizontal, isCompact ? 12 : 0)
         .padding(.vertical, isCompact ? 12 : 0)
         .background(isCompact ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 16))
         .contextMenu {
             Section {
               Button {
                   navigationManager.path.append(PostFeedType.user(post.author))
               } label: {
                   Label {
                       Text(post.author)
                   } icon: {
                       Image(systemName: "person")
                   }
               }
             }

             if !isCompact {
                 Button {
                     showTextSelection.toggle()
                 } label: {
                     Label("Select text", systemImage: "selection.pin.in.out")
                 }
             }

             toggleSaveButton

             if let redditURL = post.redditURL {
               ShareLink(item: redditURL) {
                   Label("Share", systemImage: "square.and.arrow.up")
               }
             }
         } preview: {
             CompactPostView(post: post)
                 .padding(15)
                 .frame(maxWidth: 400)
                 .environment(navigationManager)
         }
         #if !os(macOS)
         .sheet(isPresented: $showTextSelection) {
             TextSelectionView(content: post.selftext)
         }
         #endif
         .sheet(isPresented: $showCommentSheet) {
             if let addOptimisticTopLevelComment = addOptimisticTopLevelComment {
                 ReplySheet(parentId: post.id, isTopLevel: true) { text, postId in
                     addOptimisticTopLevelComment(text, postId)
                 }
                 #if !os(macOS)
                 .navigationTransition(.zoom(sourceID: "reply-button", in: transition))
                 #endif
             }
         }
    }

    func toggleSave() async {
        let success = await RedditAPI.save(!isSaved, id: post.fullname)
        if success {
            isSaved.toggle()
        }
    }

    var toggleSaveButton: some View {
        Button {
            Task {
              await toggleSave()
            }
        } label: {
            Label(isSaved ? "Unsave" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                .padding(2)
        }
        .foregroundStyle(isSaved ? .green : .secondary)
    }
}
