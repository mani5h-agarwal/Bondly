//
//  Button.swift
//  Bondly
//
//  Created by Manish Agarwal on 06/05/25.
//

import SwiftUI

struct CustomButton: View {
    
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(title)
            }
            .font(.title3)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color(red: 0.5, green: 0.3, blue: 0.8).gradient)
            .foregroundColor(.white)
            .cornerRadius(.infinity)
        }
        .padding(.horizontal)
        .disabled(isLoading)
    }
}
