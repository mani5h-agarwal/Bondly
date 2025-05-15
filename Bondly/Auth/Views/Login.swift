//
//  Login.swift
//  Bondly
//
//  Created by Manish Agarwal on 06/05/25.
//

import SwiftUI

struct Login: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 15) {
            InputField(text: $email, title: "Email", isSecure: false, systemImageName: "envelope")
            PasswordInputField(password: $password)

            CustomButton(title: "Login", action:  {
                Task {
                    await authViewModel.handleLogin(email: email, password: password)
                }
            }, isLoading: authViewModel.isLoading)
            .padding(.top, 10)

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}
