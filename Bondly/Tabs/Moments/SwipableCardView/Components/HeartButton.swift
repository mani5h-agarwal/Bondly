////
////  HeartButton.swift
////  Bondly
////
////  Created by Manish Agarwal on 12/05/25.
////
//
//import SwiftUI
//
//struct HeartButton: View {
//    @State private var isLiked = false
//    @State private var scale: CGFloat = 1.0
//
//    var body: some View {
//        Button(action: {
//            if !isLiked {
//                isLiked = true
//                withAnimation(.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0)) {
//                    scale = 1.3
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//                    withAnimation(.spring()) {
//                        scale = 1.0
//                    }
//                }
//            } else {
//                isLiked = false
//            }
//        }) {
//            Image(systemName: isLiked ? "heart.fill" : "heart")
//                .foregroundColor(isLiked ? .red : .gray)
//                .font(.system(size: 30))
//                .scaleEffect(scale)
//        }
//    }
//}

import SwiftUI

struct HeartButton: View {
    @ObservedObject var momentVM: MomentViewModel
    var moment: Moment
    var userId: String
    
    @State private var scale: CGFloat = 1.0
    
    // Reflect current like state from the passed moment
    private var isLiked: Bool {
        moment.isLikedByCurrentUser
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                scale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring()) {
                    scale = 1.0
                }
            }
            momentVM.toggleLike(for: moment, userId: userId)
        }) {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .foregroundColor(isLiked ? .red : .gray)
                .font(.system(size: 30))
                .scaleEffect(scale)
        }
    }
}
