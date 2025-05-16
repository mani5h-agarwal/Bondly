//
//  EmptyStateView.swift
//  Bondly
//
//  Created by Manish Agarwal on 16/05/25.
//
import SwiftUI

struct EmptyStateView: View {
    let title: String
    var message: String? = nil
    let systemImage: String
    var withMessage: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(title)
                .font(.headline)
            
            if withMessage, let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
}

