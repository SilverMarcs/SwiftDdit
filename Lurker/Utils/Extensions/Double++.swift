//
//  Double++.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 19/06/2025.
//

import Foundation

// MARK: - Time Formatting
extension Double {
    /// Format Unix timestamp to relative time string (e.g., "2h", "5d", "now")
    var timeAgo: String {
        let timeInterval = Date().timeIntervalSince1970 - self
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        if days > 0 {
            return "\(days)d"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "now"
        }
    }
}

extension Optional where Wrapped == Double {
    var timeAgo: String? {
        switch self {
        case .some(let value):
            return value.timeAgo
        case .none:
            return nil
        }
    }
}
