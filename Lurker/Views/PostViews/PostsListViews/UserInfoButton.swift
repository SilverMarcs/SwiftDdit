//
//  UserInfoButton.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct UserInfoButton: ToolbarContent {
    let username: String
    @State private var showingUserInfo = false
    @Namespace private var transition

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingUserInfo = true
            } label: {
                Image(systemName: "u.circle")
            }
            .sheet(isPresented: $showingUserInfo) {
                UserInfoView(username: username)
                    #if !os(macOS)
                        .navigationTransition(.zoom(sourceID: "user-info-\(username)", in: transition))
                    #endif
            }
        }
        #if !os(macOS)
            .matchedTransitionSource(id: "user-info-\(username)", in: transition)
        #endif
    }
}
