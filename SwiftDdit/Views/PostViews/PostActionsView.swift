//
//  PostActionsView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct PostActionsView: View {
    let post: Post
    private var viewModel: VoteActionViewModel

    init(post: Post) {
        self.post = post
        viewModel = VoteActionViewModel(item: post, targetType: .post)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: { viewModel.vote(action: .up) }) {
                Image(systemName: "arrow.up")
                    .font(.title2)
                    .foregroundStyle(viewModel.likes == true ? .indigo : .secondary)
            }
            .buttonStyle(.plain)

            Text(viewModel.formattedUpsCount)
                .contentTransition(.numericText())
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(viewModel.likes == true ? .indigo : viewModel.likes == false ? .red : .secondary)

            Button(action: { viewModel.vote(action: .down) }) {
                Image(systemName: "arrow.down")
                    .font(.title2)
                    .foregroundStyle(viewModel.likes == false ? .red : .secondary)
            }
            .buttonStyle(.plain)
        }
        .lineLimit(1)
        .fontWeight(.semibold)
        .padding(8)
        .glassEffect(.regular.interactive())
    }
}
