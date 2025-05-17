////
////  ChipsContentView.swift
////  Bondly
////
////  Created by Manish Agarwal on 12/05/25.
////
import SwiftUI

@ViewBuilder
func ChipView(_ tag: String, index: Int, isSelected: Bool) -> some View {
    let backgroundColor = tagColors[index % tagColors.count]
    
    HStack(spacing: 10) {
        Text(tag)
            .font(.caption)
            .foregroundStyle(isSelected ? .white : Color.primary)
        
        if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.white)
        }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background {
        ZStack {
            Capsule()
                .fill(backgroundColor)
                .opacity(!isSelected ? 1 : 0)
            Capsule()
                .fill(.green.gradient)
                .opacity(isSelected ? 1 : 0)
        }
    }
}
