//
//  RedditCredential.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 16/06/25.
//

import Foundation
import SwiftUI

struct RedditCredential: Identifiable, Equatable, Hashable, Codable {
    var id: UUID
    var sessionCookie: String?
    var userName: String?
    var profilePicture: String?

    var validationStatus: CredentialValidationState {
        if sessionCookie != nil && userName != nil {
            return .authorized
        }
        return .empty
    }

    init(
        sessionCookie: String? = nil,
        userName: String? = nil,
        profilePicture: String? = nil
    ) {
        self.id = UUID()
        self.sessionCookie = sessionCookie
        self.userName = userName
        self.profilePicture = profilePicture
    }

    mutating func clearIdentity() {
        sessionCookie = nil
        userName = nil
        profilePicture = nil
    }

    enum CredentialValidationState: String {
        case authorized, empty

        var meta: Meta {
            switch self {
            case .authorized:
                .init(color: .green, label: "Authorized", description: "This account is ready to use.")
            case .empty:
                .init(color: .red, label: "Not Connected", description: "This account needs to be connected.")
            }
        }

        struct Meta {
            let color: Color
            let label: String
            let description: String
        }
    }
}
