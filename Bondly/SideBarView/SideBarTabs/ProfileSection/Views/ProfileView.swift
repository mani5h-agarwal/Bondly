//////
//////  ProfileView.swift
//////  Bondly
//////
//////  Created by Manish Agarwal on 13/05/25.
//////
//
//import SwiftUI
//
//struct ProfileView: View {
//
//    @StateObject private var specificUserViewModel = UserViewModel()
//    @EnvironmentObject var currentUserViewModel: UserViewModel
//    @EnvironmentObject var bondViewModel: BondViewModel
//    @State private var isEditing: Bool = false
//    @State private var editedAboutMe: String = ""
//    @State private var localInterests: [String] = []
//    @State private var editedFullName: String = ""
//    @State private var isRefreshing: Bool = false
//    @State private var hasLoadedProfile = false
//    
//    var userId: String? = nil
//    
//    var isCurrentUser: Bool { userId == nil }
//    
//    private var viewModel: UserViewModel {
//        isCurrentUser ? currentUserViewModel : specificUserViewModel
//    }
//    
//
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                if let user = viewModel.user {
//
//                    if isCurrentUser {
//                        HStack {
//                            Spacer()
//                            Button(action: {
//                                withAnimation(.easeInOut(duration: 0.2)) {
//                                    if isEditing {
//                                        // Cancel editing
//                                        editedAboutMe = user.aboutMe
//                                        editedFullName = user.fullname
//                                        localInterests = user.interests
//                                    } else {
//                                        // Start editing
//                                        editedAboutMe = user.aboutMe
//                                        editedFullName = user.fullname
//                                        localInterests = user.interests
//                                    }
//                                    isEditing.toggle()
//                                }
//                            }) {
//                                Text(isEditing ? "Cancel" : "Edit")
//                                    .foregroundColor(Color.purple)
//                                    .padding(.horizontal, 12)
//                                    .padding(.vertical, 6)
//                                    .background(Color.purple.opacity(0.1))
//                                    .cornerRadius(8)
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//                    
//                    ProfileHeaderView(
//                        profileImage: "person.circle.fill",
//                        fullName: user.fullname,
//                        userName: user.username,
//                        bondsCount: user.bondsCount,
//                        editedFullName: $editedFullName,
//                        isEditing: $isEditing
//                    )
//
//                    VStack(alignment: .leading, spacing: 16) {
//                        AboutSectionView(
//                            aboutMe: user.aboutMe,
//                            editedAboutMe: $editedAboutMe,
//                            isEditing: $isEditing
//                        )
//
//                        if isEditing {
//                            InterestSectionView(
//                                title: "Select Interests",
//                                tags: allTags,
//                                selectedTags: $localInterests,
//                                editable: true
//                            )
//                        } else if !user.interests.isEmpty {
//                            InterestSectionView(
//                                title: "Interests",
//                                tags: user.interests,
//                                selectedTags: .constant(user.interests),
//                                editable: false
//                            )
//                        }
//                        
//                        if isEditing {
//                            HStack {
//                                Spacer()
//                                Button(action: {
//                                    Task {
//                                        if editedAboutMe != user.aboutMe {
//                                            try? await viewModel.updateAboutMe(editedAboutMe)
//                                        }
//                                        if editedFullName != user.fullname {
//                                            try? await viewModel.updateFullName(editedFullName)
//                                        }
//                                        if localInterests != user.interests {
//                                            try? await viewModel.updateInterests(localInterests)
//                                        }
//                                        isEditing = false
//                                    }
//                                }) {
//                                    Text("Save Changes")
//                                        .padding(.horizontal, 15)
//                                        .padding(.vertical, 8)
//                                        .background(Color("brandPrimary").gradient)
//                                        .foregroundColor(.white)
//                                        .clipShape(Capsule())
//                                }
//                            }
//                            .padding(.top, 10)
//                        }
//                        
//                        if !isCurrentUser, let currentUser = currentUserViewModel.user, let targetUser = viewModel.user {
//                            BondButton(
//                                currentUser: currentUser,
//                                targetUser: targetUser,
//                                onSendBondRequest: {
//                                    try? await bondViewModel.sendBondRequest(from: currentUser.id, to: targetUser.id)
//                                    await refreshUserData()
//                                },
//                                onCancelBondRequest: {
//                                    try? await bondViewModel.cancelBondRequest(from: currentUser.id, to: targetUser.id)
//                                    await refreshUserData()
//                                },
//                                onAcceptBondRequest: {
//                                    try? await bondViewModel.acceptBondRequest(currentUserId: currentUser.id, from: targetUser.id)
//                                    await refreshUserData()
//                                },
//                                onRejectBondRequest: {
//                                    try? await bondViewModel.rejectBondRequest(currentUserId: currentUser.id, from: targetUser.id)
//                                    await refreshUserData()
//                                },
//                                onRemoveBond: {
//                                    try? await bondViewModel.removeBond(between: currentUser.id, and: targetUser.id)
//                                    await refreshUserData()
//                                }
//                            )
//                            .padding(.top, 10)
//                            .disabled(isRefreshing)
//                        }
//                    }
//                    .padding()
//                    .background(Color.gray.opacity(0.02))
//                    .cornerRadius(12)
//                } else {
//                    ProgressView()
//                        .foregroundStyle(Color("brandPrimary"))
//                        .padding()
//                }
//
//                Spacer()
//            }
//            .padding()
//        }
//        .refreshable {
//            isRefreshing = true
//            await refreshUserData()
//            isRefreshing = false
//        }
//        .task {
//            if !hasLoadedProfile {
//                hasLoadedProfile = true
//                await loadUserProfile()
//            }
//        }
//    }
//    
//    private func loadUserProfile() async {
//        if let specificUserId = userId {
//            if let specificUser = await specificUserViewModel.fetchSpecificUser(userId: specificUserId) {
//                localInterests = specificUser.interests
//                editedAboutMe = specificUser.aboutMe
//                editedFullName = specificUser.fullname
//
//                // Assign the fetched user explicitly to the view model
//                specificUserViewModel.user = specificUser
//                
//                await currentUserViewModel.fetchUser()
//
////                print("✅ Loaded specific user: \(specificUser)")
//            } else {
//                print("❌ Failed to load specific user")
//            }
//        } else {
////             Load the current authenticated user
//            await currentUserViewModel.fetchUser(forceRefresh: true)
//            if let user = currentUserViewModel.user {
//                localInterests = user.interests
//                editedAboutMe = user.aboutMe
//                editedFullName = user.fullname
//                print("✅ Loaded current user: \(user)")
//            }
//        }
//    }
//    
//    private func refreshUserData() async {
//        // Force refresh both current user and target user
//        await currentUserViewModel.fetchUser(forceRefresh: true)
//
//        // If viewing another user's profile, refresh that user too
//        if let specificUserId = userId {
//            if let specificUser = await specificUserViewModel.fetchSpecificUser(userId: specificUserId) {
//                // Important: explicitly update the view model
//                specificUserViewModel.user = specificUser
//                print("🔄 Refreshed target user: \(specificUser.username)")
//            }
//        }
//    }
//}

import SwiftUI

struct ProfileView: View {
    // For the specific user being viewed (might be current or other user)
    @StateObject private var specificUserViewModel = UserViewModel()
    
    // For the currently logged-in user
    @EnvironmentObject var currentUserViewModel: UserViewModel
    @EnvironmentObject var bondViewModel: BondViewModel
    
    @State private var isEditing: Bool = false
    @State private var editedAboutMe: String = ""
    @State private var localInterests: [String] = []
    @State private var editedFullName: String = ""
    @State private var isRefreshing: Bool = false
    
    // Track if the initial profile load has happened
    @State private var hasLoadedProfile = false
    
    // The ID of the user to display (nil means show current user)
    var userId: String? = nil
    
    // Helper to determine if we're viewing the current user's profile
    var isCurrentUser: Bool { userId == nil }
    
    // Use the appropriate view model based on whose profile we're viewing
    private var viewModel: UserViewModel {
        isCurrentUser ? currentUserViewModel : specificUserViewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let user = viewModel.user {
                    if isCurrentUser {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if isEditing {
                                        // Cancel editing
                                        editedAboutMe = user.aboutMe
                                        editedFullName = user.fullname
                                        localInterests = user.interests
                                    } else {
                                        // Start editing
                                        editedAboutMe = user.aboutMe
                                        editedFullName = user.fullname
                                        localInterests = user.interests
                                    }
                                    isEditing.toggle()
                                }
                            }) {
                                Text(isEditing ? "Cancel" : "Edit")
                                    .foregroundColor(Color.purple)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.purple.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    ProfileHeaderView(
                        profileImage: "person.circle.fill",
                        fullName: user.fullname,
                        userName: user.username,
                        bondsCount: user.bondsCount,
                        editedFullName: $editedFullName,
                        isEditing: $isEditing
                    )

                    VStack(alignment: .leading, spacing: 16) {
                        AboutSectionView(
                            aboutMe: user.aboutMe,
                            editedAboutMe: $editedAboutMe,
                            isEditing: $isEditing
                        )

                        if isEditing {
                            InterestSectionView(
                                title: "Select Interests",
                                tags: allTags,
                                selectedTags: $localInterests,
                                editable: true
                            )
                        } else if !user.interests.isEmpty {
                            InterestSectionView(
                                title: "Interests",
                                tags: user.interests,
                                selectedTags: .constant(user.interests),
                                editable: false
                            )
                        }
                        
                        if isEditing {
                            HStack {
                                Spacer()
                                Button(action: {
                                    Task {
                                        if editedAboutMe != user.aboutMe {
                                            try? await viewModel.updateAboutMe(editedAboutMe)
                                        }
                                        if editedFullName != user.fullname {
                                            try? await viewModel.updateFullName(editedFullName)
                                        }
                                        if localInterests != user.interests {
                                            try? await viewModel.updateInterests(localInterests)
                                        }
                                        isEditing = false
                                    }
                                }) {
                                    Text("Save Changes")
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(Color("brandPrimary").gradient)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.top, 10)
                        }
                        
                        if !isCurrentUser, let currentUser = currentUserViewModel.user, let targetUser = viewModel.user {
                            BondButton(
                                currentUser: currentUser,
                                targetUser: targetUser,
                                onSendBondRequest: {
                                    try? await bondViewModel.sendBondRequest(from: currentUser.id, to: targetUser.id)
                                    await refreshUserData()
                                },
                                onCancelBondRequest: {
                                    try? await bondViewModel.cancelBondRequest(from: currentUser.id, to: targetUser.id)
                                    await refreshUserData()
                                },
                                onAcceptBondRequest: {
                                    try? await bondViewModel.acceptBondRequest(currentUserId: currentUser.id, from: targetUser.id)
                                    await refreshUserData()
                                },
                                onRejectBondRequest: {
                                    try? await bondViewModel.rejectBondRequest(currentUserId: currentUser.id, from: targetUser.id)
                                    await refreshUserData()
                                },
                                onRemoveBond: {
                                    try? await bondViewModel.removeBond(between: currentUser.id, and: targetUser.id)
                                    await refreshUserData()
                                }
                            )
                            .padding(.top, 10)
                            .disabled(isRefreshing)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.02))
                    .cornerRadius(12)
                } else {
                    ProgressView()
                        .foregroundStyle(Color("brandPrimary"))
                        .padding()
                }

                Spacer()
            }
            .padding()
        }
        .refreshable {
            isRefreshing = true
            await refreshUserData()
            isRefreshing = false
        }
        .onAppear {
            // Only load the profile data once when the view appears
            if !hasLoadedProfile {
                hasLoadedProfile = true
                Task {
                    await loadUserProfile()
                }
            }
        }
    }
    
    private func loadUserProfile() async {
        if let specificUserId = userId {
            // Loading another user's profile
            if let specificUser = await specificUserViewModel.fetchSpecificUser(userId: specificUserId) {
                localInterests = specificUser.interests
                editedAboutMe = specificUser.aboutMe
                editedFullName = specificUser.fullname

                // Assign the fetched user explicitly to the view model
                specificUserViewModel.user = specificUser
                
                // Make sure we have current user data for comparison (bonds, etc.)
                if currentUserViewModel.user == nil {
                    await currentUserViewModel.fetchUser()
                }
            } else {
                print("❌ Failed to load specific user")
            }
        } else {
            // Loading the current user's profile
            if currentUserViewModel.user == nil {
                await currentUserViewModel.fetchUser(forceRefresh: true)
            }
            
            if let user = currentUserViewModel.user {
                localInterests = user.interests
                editedAboutMe = user.aboutMe
                editedFullName = user.fullname
            }
        }
    }
    
    private func refreshUserData() async {
        // Force refresh both current user and target user
        await currentUserViewModel.fetchUser(forceRefresh: true)

        // If viewing another user's profile, refresh that user too
        if let specificUserId = userId {
            if let specificUser = await specificUserViewModel.fetchSpecificUser(userId: specificUserId) {
                // Important: explicitly update the view model
                specificUserViewModel.user = specificUser
            }
        }
    }
}
