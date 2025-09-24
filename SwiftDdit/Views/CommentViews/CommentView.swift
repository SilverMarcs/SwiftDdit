//
//  CommentView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct CommentView: View {
    let comment: Comment
    let isCollapsed: Bool
    let onToggleCollapse: (String) -> Void
    
    @Environment(\.addOptimisticComment) var addOptimisticComment
    @State private var showReplySheet = false
    @State private var showTextSelection = false
    
    private let maxDepth = 8
    
    var body: some View {
        Button {
            if comment.hasChildren {
                withAnimation(.easeInOut(duration: 0.2)) {
                    onToggleCollapse(comment.id)
                }
            }
        } label: {
            HStack(alignment: .top, spacing: 0) {
                // Visual depth indicator
                if comment.depth > 0 {
                    if comment.depth > 1 {
                        Spacer()
                            .frame(width: CGFloat((comment.depth - 1) * 12))
                    }
                    Rectangle()
                        .fill(comment.depthColor)
                        .frame(width: 2)
                        .padding(.trailing, 9)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    CommentHeader(comment: comment)
                    
                    if !isCollapsed {
                        Text(LocalizedStringKey(comment.body))
                            .font(.default)
                            .opacity(0.85)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    if comment.hasChildren && isCollapsed {
                        Text("[\(comment.childCount) \(comment.childCount == 1 ? "reply" : "replies")]")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                }
                .contentShape(.rect)
                
                Spacer()
            }
            .id(comment.id)
            .opacity(isCollapsed && comment.hasChildren ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                showReplySheet = true
            } label: {
                Label("Reply", systemImage: "arrowshape.turn.up.left")
            }
            
            Button {
                showTextSelection.toggle()
            } label: {
                Label("Select text", systemImage: "selection.pin.in.out")
            }
        }
        #if !os(macOS)
        .sheet(isPresented: $showTextSelection) {
            TextSelectionView(content: comment.body)
        }
        #endif
        .sheet(isPresented: $showReplySheet) {
            ReplySheet(parentId: comment.id, isTopLevel: false) { text, parentId in
                addOptimisticComment(text, parentId)
            }
        }
    }
}
