//
//  AppIconPicker.swift
//  SwiftDdit
//

#if os(iOS) || os(tvOS) || os(visionOS)
import SwiftUI

struct AppIconPicker: View {
    @State private var currentIcon: String? = UIApplication.shared.alternateIconName

    private let icons: [(name: String?, displayName: String)] = [
        (nil, "Default"),
        ("AppIconOld", "Classic"),
    ]

    var body: some View {
        Form {
            Section {
                ForEach(icons, id: \.displayName) { icon in
                    Button {
                        setIcon(icon.name)
                    } label: {
                        HStack(spacing: 14) {
                            Text(icon.displayName)
                                .foregroundStyle(.primary)

                            Spacer()

                            if currentIcon == icon.name {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.accent)
                            }
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("App Icon")
        .toolbarTitleDisplayMode(.inline)
    }

    private func setIcon(_ name: String?) {
        guard currentIcon != name else { return }
        UIApplication.shared.setAlternateIconName(name) { error in
            if error == nil {
                currentIcon = name
            }
        }
    }
}
#endif
