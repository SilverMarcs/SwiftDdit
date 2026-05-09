//
//  InboxView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct InboxView: View {
    @State private var messages: [Message] = []
    @State private var isLoading = false
    @State private var after: String?
    
    var body: some View {
        List {
            ForEach(messages, id: \.self) { message in
                MessageRowView(message: message)
            }
            
            if !messages.isEmpty {
                Color.clear
                    .frame(height: 1)
                    .onAppear {
                        Task {
                            await loadMoreMessages()
                        }
                    }
                    .listRowSeparator(.hidden)
            }
            
            if isLoading {
                Section {
                    LoadingIndicator()
                }
                .listRowBackground(Color.clear)
            }
        }
        .contentMargins(.top, 5)
        .navigationTitle("Inbox")
        .toolbarTitleDisplayMode(.inline)
        .refreshable {
            await fetchMessages()
        }
        .task {
            guard messages.isEmpty else { return }
            await fetchMessages()
        }
    }
    
    private func fetchMessages() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        if let result = await RedditAPI.fetchInbox() {
            withAnimation {
                messages = result.0 ?? []
            }
            after = result.1
        }
    }
    
    private func loadMoreMessages() async {
        guard !isLoading,
              let after = after,
              !after.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        if let result = await RedditAPI.fetchInbox(after: after) {
            let newMessages = result.0 ?? []
            messages.append(contentsOf: newMessages)
            self.after = result.1
        }
    }
}
