//
//  SwiftDditApp.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 15/06/2025.
//

import SwiftUI
import AVKit

@main
struct LurkerApp: App {
    var body: some Scene {
        #if os(macOS)
        Window("Lurker", id: "Lurker") {
            ContentView()
                .onAppear {
                   NSWindow.allowsAutomaticWindowTabbing = false
               }
        }
        Settings {
            NavigationStack {
                SettingsView()
                    .navigationDestinations()
            }
        }
        #else
        WindowGroup {
            ContentView()
        }
        #endif
    }
    
    #if !os(macOS)
    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
    }
    #endif
}
