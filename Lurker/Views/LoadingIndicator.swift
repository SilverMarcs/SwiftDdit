//
//  LoadingIndicator.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import SwiftUI

struct LoadingIndicator: View {
    var body: some View {
        ProgressView()
            .controlSize(.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .listRowSeparator(.hidden)
    }
}
