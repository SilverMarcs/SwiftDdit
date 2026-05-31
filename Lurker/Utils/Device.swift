//
//  Device.swift
//  SwiftDdit
//
//  Created by Antigravity on 31/05/2026.
//

import SwiftUI

public enum Device {
    public static var isIPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }
    
    public static var isMac: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }
    
    public static var isIPhone: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }
    
    public static var isMacOrPad: Bool {
        isMac || isIPad
    }
}

extension View {
    var isIPad: Bool { Device.isIPad }
    var isMac: Bool { Device.isMac }
    var isIPhone: Bool { Device.isIPhone }
    var isMacOrPad: Bool { Device.isMacOrPad }
}
