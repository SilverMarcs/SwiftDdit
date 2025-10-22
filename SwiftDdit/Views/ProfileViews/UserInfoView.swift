//
//  UserInfoView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct UserInfoView: View {
    let username: String
    @State private var isFollowing = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            LabeledContent("Username", value: "u/\(username)")

            Section("Actions") {
                HStack {
                    Text("Follow User")

                    Spacer()

                    if isLoading {
                        ProgressView()
                    } else {
                        Button {
                            Task {
                                await toggleFollow()
                            }
                        } label: {
                            Text(isFollowing ? "Following" : "Follow")
                                .foregroundStyle(isFollowing ? .green : .blue)
                        }
                        .buttonStyle(.borderless)
                    }
                }
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

    func toggleFollow() async {
        isLoading = true
        errorMessage = nil

        let success: Bool
        if isFollowing {
            success = await RedditAPI.unfollowUser(username)
        } else {
            success = await RedditAPI.followUser(username)
        }

        if success {
            isFollowing.toggle()
        } else {
            errorMessage = "Failed to \(isFollowing ? "unfollow" : "follow") user"
        }

        isLoading = false
    }
}

#Preview {
    UserInfoView(username: "testuser")
}
