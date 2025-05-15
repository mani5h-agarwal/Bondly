//
//  SideBarMenuView.swift
//  Bondly
//
//  Created by Manish Agarwal on 09/05/25.
//
import SwiftUI

struct SideBarMenuView: View {
    let safeArea: UIEdgeInsets
    @Binding var selectedTab: Tab?
    @Binding var showMenu: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bondly")
                .font(.largeTitle.bold())
                .padding(.bottom, 10)
            
            SideBarButton(.home) {
                selectedTab = .home
                showMenu = false
            }
            SideBarButton(.profile) {
                selectedTab = .profile
                showMenu = false
            }
            SideBarButton(.notifications) {
                selectedTab = .notifications
                showMenu = false
            }

            Spacer(minLength: 0)

            SideBarButton(.logout) {
                Task {
                    await authViewModel.handleLogout()
                    userViewModel.clearUserCache()
                    userViewModel.user = nil
                }
            }
        }
        .padding(.leading, 30)
        .padding(.vertical, 20)
        .padding(.top, safeArea.top)
        .padding(.bottom, safeArea.bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .environment(\.colorScheme, .dark)
    }
}
