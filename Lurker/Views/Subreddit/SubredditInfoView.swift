//
//  SubredditInfoView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 19/06/2025.
//

import SwiftUI

struct SubredditInfoView: View {
    let subreddit: Subreddit
    @State private var isSubscribed: Bool
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    init(subreddit: Subreddit) {
        self.subreddit = subreddit
        self._isSubscribed = State(initialValue: subreddit.isSubscribed)
    }
    
    var body: some View {
        Form {
            LabeledContent("Subreddit", value: subreddit.displayNamePrefixed)
            
            Section("Statistics") {
                if !subreddit.displayName.hasPrefix("u_") {
                    LabeledContent("Subscribers", value: subreddit.formattedSubscriberCount)
                }
                
                LabeledContent {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button {
                            Task {
                                await toggleSubscribe()
                            }
                        } label: {
                            Text(isSubscribed ? "Unsubscribe" : "Subscribe")
                                .foregroundStyle(isSubscribed ? .red : .blue)
                        }
                        .buttonStyle(.borderless)
                    }
                } label: {
                    Text("Subscription")
                }
            }
            
            Section("Description") {
                Text(subreddit.publicDescription.isEmpty ? "No description available" : subreddit.publicDescription)
                    .font(.body)
            }
            
            if let errorMessage = errorMessage {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .formStyle(.grouped)
        .presentationDetents([.medium])
    }
    
    func toggleSubscribe() async {
        isLoading = true
        errorMessage = nil
        
        let success: Bool
        let isUser = subreddit.displayName.hasPrefix("u_")
        let name = isUser ? String(subreddit.displayName.dropFirst(2)) : subreddit.displayName
        
        if isSubscribed {
            success = isUser ? await RedditAPI.unfollowUser(name) : await RedditAPI.unsubscribeFromSubreddit(name)
        } else {
            success = isUser ? await RedditAPI.followUser(name) : await RedditAPI.subscribeToSubreddit(name)
        }
        
        if success {
            isSubscribed.toggle()
        } else {
            errorMessage = "Failed to \(isSubscribed ? "unsubscribe from" : "subscribe to") \(isUser ? "user" : "subreddit")"
        }
        
        isLoading = false
    }
}
