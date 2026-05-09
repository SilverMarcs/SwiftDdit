//
//  LinkButton.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 15/07/2025.
//

import SwiftUI

struct LinkButton: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundStyle(iconColor)
                    
                    Text(title)
                        .bold()
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary.opacity(0.6))
                    .font(.system(size: 13.5, weight: .semibold))
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .light ? AnyShapeStyle(.background.tertiary) : AnyShapeStyle(.background.secondary))
        )
    }
}
