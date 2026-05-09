//
//  CommentActionsView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct CommentActionsView: View {
    let comment: Comment
    private var viewModel: VoteActionViewModel
    
    init(comment: Comment) {
        self.comment = comment
        viewModel = VoteActionViewModel(item: comment, targetType: .comment)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: { viewModel.vote(action: .up) }) {
                Image(systemName: "arrow.up")
                    .font(.subheadline)
                    .foregroundStyle(viewModel.likes == true ? .indigo : .secondary)
            }
            .buttonStyle(.plain)
            
            Text(viewModel.formattedUpsCount)
                .contentTransition(.numericText())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(viewModel.likes == true ? .indigo : viewModel.likes == false ? .red : .secondary)
            
            Button(action: { viewModel.vote(action: .down) }) {
                Image(systemName: "arrow.down")
                    .font(.subheadline)
                    .foregroundStyle(viewModel.likes == false ? .red : .secondary)
            }
            .buttonStyle(.plain)
        }
        .fontWeight(.semibold)
        .padding(8)
        .glassEffect(.regular.interactive())
    }
}
