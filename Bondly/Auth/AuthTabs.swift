//
//  AuthTabs.swift
//  Bondly
//
//  Created by Manish Agarwal on 06/05/25.
//
import SwiftUI

struct AuthTabs: View {
    @State private var selectedTab = "Login"

    var body: some View {
        VStack {
            Text("Welcome Back 👋")
                .font(.largeTitle)
                .bold()
                .padding(.top, 50)

            Picker("Authentication", selection: $selectedTab) {
                Text("Login").tag("Login")
                Text("Signup").tag("Sign Up")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 30)
            .padding(.vertical, 30)

            if selectedTab == "Login" {
                Login()
            } else {
                SignUp()
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
}

#Preview {
    AuthTabs()
}
