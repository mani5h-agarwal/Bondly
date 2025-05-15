//
//  SideBarButton.swift
//  Bondly
//
//  Created by Manish Agarwal on 09/05/25.
//

import SwiftUI
@ViewBuilder
func SideBarButton(_ tab: Tab, onTap: @escaping () -> () = { }) -> some View {
    Button(action: onTap, label: {
        HStack(spacing: 12) {
            Image (systemName: tab.rawValue)
                .font(.title3)
            Text (tab.title)
                .font(.callout)
            Spacer (minLength: 0)
        }
        .padding(.vertical, 10)
        .contentShape(.rect)
        .foregroundStyle (Color.primary)
    })
}

enum Tab: String, CaseIterable {
    case home = "house.fill"
    case bookmark = "book.fill"
    case favourites = "heart.fill"
    case profile = "person.crop.circle"
    case notifications = "bell.fill"
    case logout = "rectangle.portrait.and.arrow.forward.fill"
    var title: String{
        switch self {
        case .home: return "Home"
        case .bookmark: return "Bookmark"
        case .favourites: return "Favourites"
        case .profile: return "Profile"
        case .notifications: return "Notifications"
        case .logout: return "Logout"
        }
    }
}
