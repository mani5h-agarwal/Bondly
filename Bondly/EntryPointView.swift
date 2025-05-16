//
//  EntryPointView.swift
//  Bondly
//
//  Created by Manish Agarwal on 07/05/25.
//
import SwiftUI

struct EntryPointView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    var body: some View {
        ZStack {
            if isLoggedIn {
                LoggedInView()
                    .transition(.move(edge: .trailing))
            } else {
                AuthTabs()
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isLoggedIn)
    }
}
