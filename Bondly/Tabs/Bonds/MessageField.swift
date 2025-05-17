//////
//////  MessageField.swift
//////  Bondly
//////
//////  Created by Manish Agarwal on 16/05/25.
//////
import SwiftUI

struct MessageField: View {
    @State private var messageText = ""
    var onSend: (String) -> Void

    var body: some View {
        HStack {
            TextField("Type a message...", text: $messageText)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(24)

            Button {
                guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                onSend(messageText)
                messageText = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .padding()
                    .background(Color("brandPrimary"))
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}
