//
//  SettingsView.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 16/06/25.
//

import SwiftUI
import SwiftMediaViewer

struct SettingsView: View {
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = false
    @AppStorage("showAppIconPicker") var showAppIconPicker: Bool = false
    @State private var easterEggTapCount = 0

    var body: some View {
        Form {
            Section("Reddit Login") {
                NavigationLink(value: SettingsRoute.accounts) {
                    Label("Accounts", systemImage: "person.fill")
                }
            }

            #if os(iOS) || os(tvOS) || os(visionOS)
            if showAppIconPicker {
                Section {
                    NavigationLink(value: SettingsRoute.appIcon) {
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
        .toolbarTitleDisplayMode(isMacOrPad ? .inlineLarge : .inline)
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
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
