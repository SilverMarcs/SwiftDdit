//
//  Int++.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 19/06/2025.
//

import Foundation

extension Int {
    /// Format large numbers with k (thousands) or M (millions) suffix
    /// Examples: 1500 -> "1.5k", 1500000 -> "1.5M"
    var formatted: String {
        let number = Double(abs(self))
        let sign = self < 0 ? "-" : ""
        
        switch number {
        case 1_000_000...:
            let value = number / 1_000_000.0
            let formatted = unsafe String(format: value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0fM" : "%.1fM", value)
            return sign + formatted
            
        case 1_000...:
            let value = number / 1_000.0
            let formatted = unsafe String(format: value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0fk" : "%.1fk", value)
            return sign + formatted
            
        default:
            return String(self)
        }
    }
}

extension Optional where Wrapped == Int {
    var formatted: String {
        switch self {
        case .some(let value):
            return value.formatted
        case .none:
            return "0"
        }
    }
}
