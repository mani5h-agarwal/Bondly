////
////  Bonds.swift
////  Bondly
////
////  Created by Manish Agarwal on 15/05/25.
////

import SwiftUI
import FirebaseAuth

struct Bonds: View {
    @State private var selectedBondId: String? = nil
    @State private var searchText: String = ""
    @State private var isLoading = true
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading && userViewModel.user == nil {
                    ProgressView("Loading bonds...")
                        .foregroundStyle(Color("brandPrimary"))
                } else if let user = userViewModel.user, !user.bondedUserIds.isEmpty {
                    bondsList
                } else {
                    EmptyStateView(
                        title: "No Bonds Yet",
                        message: "Create bonds with other users to start chatting",
                        systemImage: "person.2.slash"
                    )
                }
            }
            .searchable(text: $searchText, prompt: "Search Bonds")
            .task {
                await loadUserData()
            }
            .refreshable {
                await loadUserData()
            }
        }
    }
    
    private var bondsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredBonds, id: \.self) { userId in
                    BondRowView(userId: userId) {
                        // Callback when row is tapped
                        selectedBondId = userId
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.top, 2)
                }
                .padding(.top, 8)
                
                Spacer()
                    .frame(height: 100) // Bottom padding
            }
        }
        .fullScreenCover(item: Binding<ChatItem?>(
            get: { selectedBondId.map { ChatItem(id: $0) } },
            set: { selectedBondId = $0?.id }
        )) { chatItem in
            ChatDetailView(userId: chatItem.id)
        }
    }
    
    private var filteredBonds: [String] {
        guard let user = userViewModel.user else { return [] }
        
        if searchText.isEmpty {
            return user.bondedUserIds
        } else {
            // We'll need to filter based on user info we have in cache
            // This is a more complex operation as we need to check names/usernames
            let searchLowercased = searchText.lowercased()
            
            // Using async filtering isn't ideal in a computed property,
            // so we'll rely on what's cached at the moment
            return user.bondedUserIds.filter { userId in
                // Check if we have this user in the cache and filter by name/username
                if let cachedPreviews = UserDefaults.standard.data(forKey: "cachedUserPreviews") {
                    do {
                        let previews = try JSONDecoder().decode([String: UserPreviewModel].self, from: cachedPreviews)
                        if let preview = previews[userId] {
                            return preview.username.lowercased().contains(searchLowercased) ||
                                   preview.fullname.lowercased().contains(searchLowercased)
                        }
                    } catch {
                        print("Failed to decode cached previews: \(error)")
                    }
                }
                
                // If no match or cache failed, include by default for now
                // A better approach would be to handle this filtering asynchronously
                return true
            }
        }
    }
    
    private func loadUserData() async {
        isLoading = true
        await userViewModel.fetchUser(forceRefresh: true)
        isLoading = false
    }
}


