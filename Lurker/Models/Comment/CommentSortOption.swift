//
//  CommentSortOption.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import Foundation

/// Comment sort options
enum CommentSortOption: String, CaseIterable {
    case confidence = "confidence"
    case top = "top"
    case new = "new"
    case controversial = "controversial"
    case old = "old"
    case random = "random"
    case qa = "qa"
    case live = "live"
    
    var displayName: String {
        switch self {
        case .confidence: return "Best"
        case .top: return "Top"
        case .new: return "New"
        case .controversial: return "Controversial"
        case .old: return "Old"
        case .random: return "Random"
        case .qa: return "Q&A"
        case .live: return "Live"
        }
    }
    
    var iconName: String {
        switch self {
        case .confidence: return "flame"
        case .top: return "trophy"
        case .new: return "newspaper"
        case .controversial: return "figure.fencing"
        case .old: return "clock.arrow.circlepath"
        case .random: return "dice"
        case .qa: return "bubble.left.and.bubble.right"
        case .live: return "dot.radiowaves.left.and.right"
        }
    }
}
