//
//  MessageField.swift
//  Bondly
//
//  Created by Manish Agarwal on 16/05/25.
//

import SwiftUI

struct MessageField: View {
    var body: some View {
        HStack(spacing: 5) {
            TextField("Type a message...", text: .constant(""))
                .padding(.horizontal, 15)
                .padding(.vertical, 13)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(24) // Rounded pill-like shape
                .padding(.leading, 8)
                .tint(Color("brandPrimary"))

            Button{
                // Send message action
            } label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .foregroundStyle(Color.white)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .padding(13)
                    .padding(.trailing, 2)
                    .background(Color("brandPrimary"))
                    .clipShape(Circle())
            }
            .padding(.trailing, 8)
        }
        .padding(.bottom, 10)
        .background(Color(.systemBackground))
    }
}
