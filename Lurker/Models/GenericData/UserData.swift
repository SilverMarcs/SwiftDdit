//
//  UserData.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 16/06/2025.
//


import Foundation

struct UserData: Codable {
    let id: String
    let name: String
    let created: Double?
    let created_utc: Double?
    let link_karma: Int?
    let comment_karma: Int?
    let total_karma: Int?
    let is_gold: Bool?
    let is_mod: Bool?
    let has_verified_email: Bool?
    let icon_img: String?
    let snoovatar_img: String?
    let subreddit: UserSubreddit?
    let modhash: String?
}

struct UserSubreddit: Codable {
    let display_name: String?
    let title: String?
    let icon_img: String?
    let over_18: Bool?
    let public_description: String?
}
