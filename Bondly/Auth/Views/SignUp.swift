//
//  SignUp.swift
//  Bondly
//
//  Created by Manish Agarwal on 06/05/25.
//

import SwiftUI

struct SignUp: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 15) {
            InputField(text: $username, title: "Username", isSecure: false, systemImageName: "person")
            InputField(text: $email, title: "Email", isSecure: false, systemImageName: "envelope")
            PasswordInputField(password: $password)
            CustomButton(title: "Sign Up", action:  {
                Task {
                    await authViewModel.handleSignup(username: username, email: email, password: password)
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
