//
//  MessageDetailView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct MessageDetailView: View {
    let message: Message
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: message.iconConfig.symbol)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(message.iconConfig.color)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let subject = message.subject, !subject.isEmpty {
                            Text(subject)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        if let subreddit = message.subredditNamePrefixed {
                            Text(subreddit)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if let author = message.author {
                            Text("u/\(author)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
                
                if let body = message.body, !body.isEmpty {
                    Text(body)
                        .font(.body)
                        .lineSpacing(4)
                }
                
                if let linkTitle = message.linkTitle, !linkTitle.isEmpty {
                    Text("Re: \(linkTitle)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .italic()
                }
                
                HStack {
                    if let timeAgo = message.timeAgo {
                        Text(timeAgo)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            .padding()
        }
        .navigationTitle("Message")
        .toolbarTitleDisplayMode(.inline)
    }
}
