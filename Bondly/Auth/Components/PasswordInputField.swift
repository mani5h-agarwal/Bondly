//
//  PsswordInputField.swift
//  Bondly
//
//  Created by Manish Agarwal on 06/05/25.
//
import SwiftUI

struct PasswordInputField: View {
    
    @Binding var password: String
    @State private var isVisible: Bool = false

    var body: some View {
        ZStack(alignment: .trailing) {
            InputField(text: $password, title: "Password", isSecure: !isVisible, systemImageName: "lock")
            
            Button(action: {
                isVisible.toggle()
            }) {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
                    .padding(.trailing, 24)
            }
        }
    }
}

//#Preview {
//    PasswordInputField(password: .constant(""))
//}
//
