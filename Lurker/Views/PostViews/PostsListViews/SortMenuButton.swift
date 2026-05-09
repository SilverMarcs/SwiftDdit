//
//  SortMenuButton.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import SwiftUI

struct SortMenuButton: View {
    @Binding var selectedSort: SubListingSortOption
    
    var body: some View {
        Menu {
            ForEach(SubListingSortOption.allCases, id: \.id) { sort in
                Button {
                    selectedSort = sort
                } label: {
                    Label(sort.displayName, systemImage: sort.icon)
                }
            }
            
            Menu {
                ForEach(SubListingSortOption.topOptions, id: \.id) { topOption in
                    Button {
                        selectedSort = topOption
                    } label: {
                        Label(topOption.displayName, systemImage: topOption.icon)
                    }
                }
            } label: {
                Label("Top", systemImage: "arrow.up.circle")
            }
        } label: {
            Label(selectedSort.displayName, systemImage: selectedSort.icon)
                .labelStyle(.iconOnly)
        }
        .menuIndicator(.hidden)
        .tint(.accent)
    }
}
