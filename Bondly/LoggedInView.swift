//
//  AppEntryView.swift
//  Bondly
//
//  Created by Manish Agarwal on 09/05/25.
//

import SwiftUI

struct LoggedInView: View {
    
    @State private var showMenu: Bool = false
    @State private var selectedTab: Tab? = .home
    
    var body: some View {
        AnimatedSideBar(
            sideMenuWidth: 200,
            cornerRadius: 25,
            showMenu: $showMenu
        ) { safeArea in
            Group {
                switch selectedTab {
                case .home:
                    AppTabView(showMenu: $showMenu)
                case .profile:
                    NavigationStack{
                        ProfileView()
                            .withLeadingMenuToolbar(title: "Profile", showMenu: $showMenu)
                    }
                case .notifications:
                    NavigationStack{
                        ProfileView()
                            .withLeadingMenuToolbar(title: "Notification", showMenu: $showMenu)
                    }
                default:
                    AppTabView(showMenu: $showMenu)
                }
            }
            
        } menuView: { safeArea in
            SideBarMenuView(
                safeArea: safeArea,
                selectedTab: $selectedTab,
                showMenu: $showMenu
            )
        } background: {
            Rectangle()
                .fill(Color(red: 0.5, green: 0.2, blue: 0.7).gradient)
        }
    }
}

#Preview {
    let authViewModel = AuthViewModel()
    let userViewModel = UserViewModel()
    return LoggedInView()
        .environmentObject(authViewModel)
        .environmentObject(userViewModel)
}


