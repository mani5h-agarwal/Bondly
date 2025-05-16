//
//  TabView.swift
//  Bondly
//
//  Created by Manish Agarwal on 06/05/25.
//

import SwiftUI

struct AppTabView: View {
    
    @State var selectedTabBottom: Int = 0
    @State private var showFABView: Bool = false
    @Binding var showMenu: Bool
    
    var body: some View {
        ZStack{
            TabView(selection: $selectedTabBottom) {
                NavigationStack{
                    Bonds()
                        .withLeadingMenuToolbar(title: "Bonds", showMenu: $showMenu)
                    
                }
                .tabItem {
                    Label("Bonds", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(0)
                
                NavigationStack{
                    Moments()
                        .withLeadingMenuToolbar(title: "Moments", showMenu: $showMenu)
                    
                }
                .tabItem {
                    Label("Moments", systemImage: "book")
                }
                .tag(1)
                
                NavigationStack{
                    Clans()
                        .withLeadingMenuToolbar(title: "Clans", showMenu: $showMenu)
                    
                }
                .tabItem {
                    Label("Clans", systemImage: "person.3.fill")
                }
                .tag(2)
            }
            .tint(Color(red: 0.5, green: 0.3, blue: 0.8))
            FAB(showFABView: $showFABView, selectedTabBottom: selectedTabBottom)
            
        }
        .fullScreenCover(isPresented: $showFABView) {
            switch selectedTabBottom {
            case 0:
                NewBondView()
            case 1:
                AddMomentView()
            case 2:
                NewBondView()
            default:
                EmptyView()
            }
        }
    }
}
//
//#Preview {
//    AppTabView()
//}
