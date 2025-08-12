//
//  Message.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import Foundation
import SwiftUI

struct Message: Codable, Identifiable, Hashable {
    let id: String
    let subject: String?
    let author: String?
    let authorFullname: String?
    let subreddit: String?
    let subredditNamePrefixed: String?
    let body: String?
    let bodyHtml: String?
    let linkTitle: String?
    let dest: String?
    let context: String?
    let parentId: String?
    let name: String?
    let type: String?
    let created: Double?
    let createdUtc: Double?
    var isNew: Bool?
    let wasComment: Bool?
    
    // Pre-computed formatted values
    let timeAgo: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case subject
        case author
        case authorFullname = "author_fullname"
        case subreddit
        case subredditNamePrefixed = "subreddit_name_prefixed"
        case body
        case bodyHtml = "body_html"
        case linkTitle = "link_title"
        case dest
        case context
        case parentId = "parent_id"
        case name
        case type
        case created
        case createdUtc = "created_utc"
        case isNew = "new"
        case wasComment = "was_comment"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.subject = try container.decodeIfPresent(String.self, forKey: .subject)
        self.author = try container.decodeIfPresent(String.self, forKey: .author)
        self.authorFullname = try container.decodeIfPresent(String.self, forKey: .authorFullname)
        self.subreddit = try container.decodeIfPresent(String.self, forKey: .subreddit)
        self.subredditNamePrefixed = try container.decodeIfPresent(String.self, forKey: .subredditNamePrefixed)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.bodyHtml = try container.decodeIfPresent(String.self, forKey: .bodyHtml)
        self.linkTitle = try container.decodeIfPresent(String.self, forKey: .linkTitle)
        self.dest = try container.decodeIfPresent(String.self, forKey: .dest)
        self.context = try container.decodeIfPresent(String.self, forKey: .context)
        self.parentId = try container.decodeIfPresent(String.self, forKey: .parentId)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.created = try container.decodeIfPresent(Double.self, forKey: .created)
        self.createdUtc = try container.decodeIfPresent(Double.self, forKey: .createdUtc)
        self.isNew = try container.decodeIfPresent(Bool.self, forKey: .isNew)
        self.wasComment = try container.decodeIfPresent(Bool.self, forKey: .wasComment)
        
        // Pre-compute timeAgo
        self.timeAgo = created.timeAgo
    }
    
    var createdDate: Date {
        if let created = created {
            return Date(timeIntervalSince1970: created)
        }
        return Date()
    }
    
    
    var iconConfig: (symbol: String, color: Color) {
        switch self.type {
        case "post_reply":
            return ("message.circle.fill", .blue)
        case "comment_reply":
            return ("arrowshape.turn.up.left.circle.fill", .green)
        case "unknown", _:
            return ("bell.circle.fill", .accent)
        }
    }
}
