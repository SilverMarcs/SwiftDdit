//
//  SwiftDditApp.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 15/06/2025.
//

import SwiftUI
import AVKit

@main
struct SwiftDditApp: App {
    @State private var settingsNavigation = SettingsNavigationCoordinator()

    var body: some Scene {
        #if os(macOS)
        Window("SwiftDdit", id: "SwiftDdit") {
            ContentView()
                .environment(settingsNavigation)
                .onAppear {
                   NSWindow.allowsAutomaticWindowTabbing = false
               }
        }
        Settings {
            SettingsView()
                .environment(settingsNavigation)
        }
        #else
        WindowGroup {
            ContentView()
                .environment(settingsNavigation)
        }
        #endif
    }
    
    #if !os(macOS)
    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
    }
    #endif
}
