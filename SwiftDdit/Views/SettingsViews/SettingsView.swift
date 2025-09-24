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
    @State private var deleteAlertPresented = false
    
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Reddit API") {
                    NavigationLink(destination: CredentialsView()) {
                        Label("Accounts", systemImage: "person.fill")
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
                
                Section("Images") {
                    Button {
                        deleteAlertPresented = true
                    } label: {
                        HStack {
                            Label {
                                Text("Clear Image Cache")
                                
                            } icon: {
                                Image(systemName: "trash")
                            }
                            
//                            Spacer()
//                            
//                            Text("{Cache Size}")
                        }
                        .contentShape(.rect)
                    }
                    #if os(macOS)
                    .buttonStyle(.plain)
                    #endif
                    .alert("Clear Image Cache", isPresented: $deleteAlertPresented) {
                        Button("Clear", role: .destructive) {
                            CachedAsyncImageConfiguration.clearAllCaches()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("This will clear all cached images, freeing up storage space.")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inline)
            #if !os(macOS)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            
                    }
                }
            }
            #endif
        }
    }
}

#Preview {
    SettingsView()
}
