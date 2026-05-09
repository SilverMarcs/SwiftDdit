//
//  SubListingSortOption.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

enum SubListingSortOption: CaseIterable, Identifiable, Equatable {
    case best
    case hot
    case new
    case controversial
    case top(TopTimePeriod)
    
    var id: String {
        switch self {
        case .best: return "best"
        case .hot: return "hot"
        case .new: return "new"
        case .controversial: return "controversial"
        case .top(let period): return "top_\(period.rawValue)"
        }
    }
    
    var displayName: String {
        switch self {
        case .best: return "Best"
        case .hot: return "Hot"
        case .new: return "New"
        case .controversial: return "Controversial"
        case .top(let period): return period.displayName
        }
    }
    
    var icon: String {
        switch self {
        case .best: return "trophy"
        case .hot: return "flame"
        case .new: return "newspaper"
        case .controversial: return "figure.fencing"
        case .top(let period): return period.icon
        }
    }
    
    var rawValue: String {
        switch self {
        case .best: return "best"
        case .hot: return "hot"
        case .new: return "new"
        case .controversial: return "controversial"
        case .top(_): return "top"
        }
    }
    
    var apiPath: String {
        switch self {
        case .best: return "best"
        case .hot: return "hot"
        case .new: return "new"
        case .controversial: return "controversial"
        case .top(_): return "top"
        }
    }
    
    var timeParameter: String? {
        switch self {
        case .top(let period): return period.rawValue
        default: return nil
        }
    }
    
    static var allCases: [SubListingSortOption] {
        return [
            .best,
            .hot,
            .new,
            .controversial,
//            .top(.all)
        ]
    }
    
    static var topOptions: [SubListingSortOption] {
        return TopTimePeriod.allCases.map { .top($0) }
    }
}

enum TopTimePeriod: String, CaseIterable, Identifiable {
    case hour = "hour"
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
    case all = "all"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .hour: return "Hour"
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        case .all: return "All Time"
        }
    }
    
    var icon: String {
        switch self {
        case .hour: return "clock"
        case .day: return "sun.max"
        case .week: return "clock.arrow.2.circlepath"
        case .month: return "calendar"
        case .year: return "globe.americas.fill"
        case .all: return "arrow.up.circle.badge.clock"
        }
    }
}
