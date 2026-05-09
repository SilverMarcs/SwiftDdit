//
//  AccountRowView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI

struct AccountRowView: View {
    let credential: RedditCredential

    private var isActive: Bool {
        CredentialsManager.shared.activeCredentialId == credential.id
    }

    var body: some View {
        Button {
            if !isActive {
                CredentialsManager.shared.setActiveCredential(credential.id)
            }
        } label: {
            HStack {
                Label {
                    Text(credential.userName ?? "Unknown User")
                    Text(credential.validationStatus.meta.label)
                } icon: {
                    Image(systemName: "key.fill")
                        .foregroundStyle(credential.validationStatus.meta.color)
                }

                Spacer()

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
