//
//  BondlyApp.swift
//  Bondly
//
//  Created by Manish Agarwal on 06/05/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct BondlyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var userViewModel = UserViewModel()
    @StateObject var bondViewModel = BondViewModel()
    var body: some Scene {
        WindowGroup {
            EntryPointView()
                .environmentObject(authViewModel)
                .environmentObject(userViewModel)
                .environmentObject(bondViewModel)
            
                .task {
                    await userViewModel.fetchUser()
                }
        }
    }
}
