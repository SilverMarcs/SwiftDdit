//
//  SettingsView.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 16/06/25.
//

import SwiftUI
import SwiftMediaViewer

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(SettingsNavigationCoordinator.self) private var settingsNavigation
    
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = false
    @AppStorage("showAppIconPicker") var showAppIconPicker: Bool = false
    @State private var easterEggTapCount = 0
    
    var body: some View {
        @Bindable var settingsNavigation = settingsNavigation

        NavigationStack(path: $settingsNavigation.path) {
            Form {
                Section("Reddit API") {
                    NavigationLink(value: SettingsNavigationCoordinator.Route.accounts) {
                        Label("Accounts", systemImage: "person.fill")
                    }
                }
                
                #if os(iOS) || os(tvOS) || os(visionOS)
                if showAppIconPicker {
                    Section {
                        NavigationLink(value: SettingsNavigationCoordinator.Route.appIcon) {
                            Label("App Icon", systemImage: "app.dashed")
                        }
                    }
                }
                #endif

                Section("Playback Settings") {
                    Toggle(isOn: $autoplay) {
                        Label("Autoplay Videos", systemImage: "play.fill")
                    }
                    Toggle(isOn: $muteOnPlay) {
                        Label("Mute on Play", systemImage: "speaker.slash.fill")
                    }
                }
                
                CacheManagerView()
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inline)
            .navigationDestination(for: SettingsNavigationCoordinator.Route.self) { route in
                switch route {
                case .accounts:
                    CredentialsView()
                case .appIcon:
                    #if os(iOS) || os(tvOS) || os(visionOS)
                    AppIconPicker()
                    #else
                    EmptyView()
                    #endif
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: 44)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        easterEggTapCount += 1
                        if easterEggTapCount >= 7 {
                            showAppIconPicker = true
                            easterEggTapCount = 0
                        }
                    }
            }
            #if !os(macOS)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
            #endif
        }
    }
}

#Preview {
    SettingsView()
        .environment(SettingsNavigationCoordinator())
}
