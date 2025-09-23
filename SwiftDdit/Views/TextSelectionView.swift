//
//  TextSelectionView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 24/09/2025.
//

import SwiftUI

struct TextSelectionView: View {
    @Environment(\.dismiss) var dismiss
    
    var content: String

    var body: some View {
        NavigationStack {
            SelectableTextView(text: content)
                .navigationTitle("Select Text")
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(role: .close) {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct SelectableTextView: UIViewRepresentable {
    let text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: UIFont.systemFontSize + 2)
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.textContainer.lineFragmentPadding = 0
        // TODO: contentInsetAdjustmentBehavior
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.sizeToFit()
    }
}
