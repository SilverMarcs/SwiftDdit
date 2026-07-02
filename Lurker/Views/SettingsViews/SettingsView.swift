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
    @AppStorage(SettingsKeys.persistFeed) var persistFeed: Bool = false
    @AppStorage(SettingsKeys.persistSort) var persistSort: Bool = false
    @AppStorage(SettingsKeys.hideFeedSwitcher) var hideFeedSwitcher: Bool = false
    @State private var easterEggTapCount = 0
    @State private var store = StoreManager.shared
    @State private var showingSupporter = false

    var body: some View {
        Form {
            Section("Reddit Login") {
                NavigationLink(value: SettingsRoute.accounts) {
                    Label("Accounts", systemImage: "person.fill")
                }
            }

            Section {
                Button {
                    showingSupporter = true
                } label: {
                    Label {
                        Text(store.isSupporter ? "Supporter" : "Support Lurker")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: store.isSupporter ? "heart.fill" : "heart")
                            .foregroundStyle(.pink)
                    }
                    // .badge(store.isSupporter ? Text("❤️") : nil)
                }
            }

            if showAppIconPicker {
                Section {
                    #if os(iOS) || os(tvOS) || os(visionOS)
                    NavigationLink(value: SettingsRoute.appIcon) {
                        Label("App Icon", systemImage: "app.dashed")
                    }
                    #endif
                    Toggle(isOn: $hideFeedSwitcher) {
                        Label("Hide Feed Switcher", systemImage: "chevron.down.circle")
                    }
                }
            }

            Section("Feeds") {
                Toggle(isOn: $persistFeed) {
                    Label("Remember Selected Feed", systemImage: "square.stack")
                }
                Toggle(isOn: $persistSort) {
                    Label("Remember Sort Order", systemImage: "arrow.up.arrow.down")
                }
            }

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
        .sheet(isPresented: $showingSupporter) { SupporterView() }
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
