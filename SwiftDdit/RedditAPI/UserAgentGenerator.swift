//
//  UserAgentGenerator.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 13/04/2026.
//

import Foundation

enum UserAgentGenerator {
    static func randomMobileSafari() -> String {
        let iosVersion = Int.random(in: 15...18)
        let iosMinor = Int.random(in: 0...6)
        let webkitVersion = Int.random(in: 600...616)
        let webkitMinor = Int.random(in: 1...99)
        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(iosVersion)_\(iosMinor) like Mac OS X) AppleWebKit/\(webkitVersion).\(webkitMinor) (KHTML, like Gecko) Version/\(iosVersion).0 Mobile/15E148 Safari/\(webkitVersion).\(webkitMinor)"
    }
}
