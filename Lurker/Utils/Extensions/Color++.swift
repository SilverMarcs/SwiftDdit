//
//  Color+Hex.swift
//  SwiftDdit
//
//  Created for flair color support
//

import SwiftUI
import Foundation

extension Color {
    /// Initialize Color from hex string
    init(hex: String) {
        let trimHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let dropHash = String(trimHex.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        let hexString = trimHex.starts(with: "#") ? dropHash : trimHex
        let ui64 = UInt64(hexString, radix: 16)
        let value = ui64 != nil ? Int(ui64!) : 0
        
        // #RRGGBB
        var components = (
            R: Double((value >> 16) & 0xff) / 255,
            G: Double((value >> 08) & 0xff) / 255,
            B: Double((value >> 00) & 0xff) / 255,
            a: 1.0
        )
        
        if String(hexString).count == 8 {
            // #RRGGBBAA
            components = (
                R: Double((value >> 24) & 0xff) / 255,
                G: Double((value >> 16) & 0xff) / 255,
                B: Double((value >> 08) & 0xff) / 255,
                a: Double((value >> 00) & 0xff) / 255
            )
        }
        
        self.init(red: components.R, green: components.G, blue: components.B, opacity: components.a)
    }
    
    /// Calculate the brightness (luminance) of the color
    /// Returns a value between 0.0 (black) and 1.0 (white)
    var brightness: Double {
        #if os(macOS)
        let color = NSColor(self)
        #else
        let color = UIColor(self)
        #endif
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        unsafe color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate relative luminance using the formula for sRGB
        return 0.299 * Double(red) + 0.587 * Double(green) + 0.114 * Double(blue)
    }
    
    /// Check if the color is too dark or too bright for good readability
    var isGoodForReadability: Bool {
        let brightness = self.brightness
        // Reject colors that are too dark (< 0.2) or too bright (> 0.8)
        return brightness >= 0.2 && brightness <= 0.8
    }
    
    /// Get a validated color that falls back to accent if too dark/bright
    static func validatedColor(from hexString: String?) -> Color? {
        guard let hexString = hexString, !hexString.isEmpty else { return nil }
        let color = Color(hex: hexString)
        return color.isGoodForReadability ? color : .accent
    }
}
