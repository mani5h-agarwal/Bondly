//
//  InputField.swift
//  Bondly
//
//  Created by Manish Agarwal on 06/05/25.
//

import SwiftUI

struct InputField: View {
    
    @Binding var text: String
    let title: String
    let isSecure: Bool
    @FocusState private var isFocused: Bool
    var systemImageName: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImageName)
                .foregroundColor(.gray)
                .frame(width: 20)

            Group {
                if isSecure {
                    SecureField(title, text: $text)
                        .focused($isFocused)
                        .tint(Color("brandPrimary"))
                } else {
                    TextField(title, text: $text)
                        .focused($isFocused)
                        .tint(Color("brandPrimary"))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(isFocused ? Color(red: 0.5, green: 0.3, blue: 0.8) : Color.gray.opacity(0.5), lineWidth: 1)
        )
        .textInputAutocapitalization(.never)
        .animation(.easeInOut, value: isFocused)
        .padding(.horizontal)
    }
}

//#Preview {
//    InputField(text: .constant(""), title: "Enter your name", isSecure: false)
//}
