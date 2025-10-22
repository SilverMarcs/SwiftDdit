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
    
    init(subreddit: Subreddit) {
        self.subreddit = subreddit
        self._isSubscribed = State(initialValue: subreddit.isSubscribed)
    }
    
    var body: some View {
        Form {
            LabeledContent("Subreddit", value: subreddit.displayNamePrefixed)
            
            Section("Statistics") {
                LabeledContent("Subscribers", value: subreddit.formattedSubscriberCount)
                
                HStack {
                    Text("Subscribed")
                    Text(subreddit.displayName)
                    
                    Spacer()
                    
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
            }
            
            Section("Description") {
                Text(subreddit.publicDescription.isEmpty ? "No description available" : subreddit.publicDescription)
                    .font(.body)
            }
        }
        .formStyle(.grouped)
        .presentationDetents([.medium, .large])
    }
    
    func toggleSubscribe() async {
        let success: Bool
        if isSubscribed {
            success = await RedditAPI.unsubscribeFromSubreddit(subreddit.displayName)
        } else {
            success = await RedditAPI.subscribeToSubreddit(subreddit.displayName)
        }
        
        if success {
            isSubscribed.toggle()
        }
    }
}
