//
//  ExpandingTextEditor.swift
//  Bondly
//
//  Created by Manish Agarwal on 12/05/25.
//

import SwiftUI

struct ExpandingTextEditor: View {
    @Binding var text: String
    @State private var textEditorHeight: CGFloat = 100
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(text.isEmpty ? "Enter your bio here..." : text)
                .font(.body)
                .foregroundColor(.clear)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .background(GeometryReader { geometry in
                    Color.clear.preference(
                        key: ViewHeightKey.self,
                        value: geometry.frame(in: .local).size.height
                    )
                })
            
            TextEditor(text: $text)
                .font(.body)
                .frame(height: max(100, textEditorHeight + 20))
                .padding(4)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
        }
        .onPreferenceChange(ViewHeightKey.self) { height in
            self.textEditorHeight = height
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
