//
//  HeartButton.swift
//  Bondly
//
//  Created by Manish Agarwal on 12/05/25.
//

import SwiftUI

struct HeartButton: View {
    @State private var isLiked = false
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button(action: {
            if !isLiked {
                isLiked = true
                withAnimation(.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0)) {
                    scale = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring()) {
                        scale = 1.0
                    }
                }
            } else {
                isLiked = false
            }
        }) {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .foregroundColor(isLiked ? .red : .gray)
                .font(.system(size: 30))
                .scaleEffect(scale)
        }
    }
}
