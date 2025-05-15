////
////  ChipsContentView.swift
////  Bondly
////
////  Created by Manish Agarwal on 12/05/25.
////
import SwiftUI


let tagColors: [Color] = [
    Color(hex: "E8E5FF"),
    Color(hex: "FFF7DA"),
    Color(hex: "ECFFDA"),
    Color(hex: "FFE9DA")
]

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 200, 200, 200)
        }

        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

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
