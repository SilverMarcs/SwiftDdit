//
//  CommentHeader.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct CommentHeader: View {
    let comment: Comment
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if comment.stickied {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                    
                    Text(comment.author)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            comment.distinguished == "moderator" ? .green :
                                (comment.isSubmitter ? .blue : .secondary)
                        )
                    
                    if let flairText = comment.authorFlairText, !flairText.isEmpty {
                        Text(flairText)
                            .lineLimit(1)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(comment.flairBackgroundColor.opacity(0.2))
                            .foregroundStyle(.secondary)
                            .cornerRadius(4)
                    }
                    
                    if comment.distinguished == "moderator" {
                        Text("MOD")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    
                    Text(comment.timeAgo)
                }
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            CommentActionsView(comment: comment)
        }
    }
}
