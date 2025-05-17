//
//  TagButton.swift
//  Bondly
//
//  Created by Manish Agarwal on 17/05/25.
//

import SwiftUI

struct TagButton: View {
    let tag: String
    @Binding var selectedTag: String
    
    var body: some View {
        Button(action: {
            selectedTag = tag
        }) {
            Text(tag)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(selectedTag == tag ? Color("brandPrimary") : Color.gray.opacity(0.2))
                )
                .font(.system(size: 14))
                .fontWeight(.medium)
                .foregroundColor(selectedTag == tag ? .white : .primary)
                .animation(.easeInOut, value: selectedTag)
        }
    }
}
