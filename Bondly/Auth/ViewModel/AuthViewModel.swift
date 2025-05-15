//
//  AuthViewModel.swift
//  Bondly
//
//  Created by Manish Agarwal on 07/05/25.
//

import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("authToken") var authToken: String = ""

    func handleLogin(email: String, password: String) async {
        isLoading = true
        do {
            let token = try await AuthManager.login(email: email, password: password)
            self.authToken = token
            self.isLoggedIn = true
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func handleSignup(username: String, email: String, password: String) async {
        isLoading = true
        do {
            let token = try await AuthManager.signup(username: username, email: email, password: password)
            self.authToken = token
            self.isLoggedIn = true
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    func handleLogout() async {
        do {
            try AuthManager.logout()
            self.authToken = ""
            self.isLoggedIn = false
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to log out: \(error.localizedDescription)"
        }
    }
}
