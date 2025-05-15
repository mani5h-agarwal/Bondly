
import SwiftUI

struct NewBondView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var newBondViewModel = NewBondViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var bondViewModel: BondViewModel
    @State private var activeTab = 0
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    tabButton(title: "Search", tag: 0)
                    tabButton(title: "Requests", tag: 1)
                    tabButton(title: "Sent", tag: 2)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                if newBondViewModel.isSearching || bondViewModel.isLoading {
                    ProgressView()
                        .foregroundStyle(Color("brandPrimary"))
                        .padding()
                }
                
                Group {
                    switch activeTab {
                    case 0:
                        searchTab
                    case 1:
                        receivedRequestsTab
                    case 2:
                        sentRequestsTab
                    default:
                        EmptyView()
                    }
                }
                .animation(.easeInOut, value: activeTab)
            }
            .navigationTitle("New Bond")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color("brandPrimary"))
                    }
                }
            }
            .task {
                await refreshUserData()
            }
            .refreshable {
                isRefreshing = true
                await refreshUserData()
                isRefreshing = false
            }
        }
        .tint(Color("brandPrimary"))
    }
    
    private var searchTab: some View {
        List {
            if newBondViewModel.searchText.isEmpty {
                EmptyStateView(
                    title: "Search for users to create a new bond",
                    systemImage: "magnifyingglass",
                    withMessage: false
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else if newBondViewModel.searchResults.isEmpty && !newBondViewModel.isSearching {
                Text("No users found matching '\(newBondViewModel.searchText)'")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(newBondViewModel.searchResults) { user in
                    if user.uid != userViewModel.user?.uid {
                        VStack{
                            HStack(spacing: 12){
                                NavigationLink(destination: ProfileView(userId: user.uid)){
                                    UserRow(user: user)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        
                    }
                }
            }
        }
        .listStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: newBondViewModel.searchText)
        .searchable(text: $newBondViewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search by username")
        .onSubmit(of: .search) {
            Task {
                await newBondViewModel.searchUsers()
            }
        }
        .onChange(of: newBondViewModel.searchText) {
            if newBondViewModel.searchText.isEmpty {
                withAnimation {
                    newBondViewModel.searchResults = []
                }
            }
        }
    }
    
    private var receivedRequestsTab: some View {
        List {
            if let currentUser = userViewModel.user, !currentUser.bondRequestsReceived.isEmpty {
                ForEach(Array(currentUser.bondRequestsReceived.keys), id: \.self) { userId in
                    if let timestamp = currentUser.bondRequestsReceived[userId] {
                        BondRequestRow(userId: userId, timestamp: timestamp, type: .received)
                            .padding(.top, 4)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .leading) {
                                Button {
                                    Task {
                                        try? await bondViewModel.acceptBondRequest(currentUserId: userViewModel.user!.uid, from: userId)
                                        await refreshUserData()
                                    }
                                } label: {
                                    Label("Accept", systemImage: "checkmark.circle")
                                }
                                .tint(Color("brandPrimary"))
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task {
                                        try? await bondViewModel.rejectBondRequest(currentUserId: userViewModel.user!.uid, from: userId)
                                        await refreshUserData()
                                    }
                                } label: {
                                    Label("Decline", systemImage: "xmark.circle")
                                }
                                .tint(.red)
                            }
                    }
                }
            } else {
                EmptyStateView(
                    title: "No Bond Requests",
                    message: "When someone sends you a bond request, it will appear here.",
                    systemImage: "envelope"
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
    }
    
    private var sentRequestsTab: some View {
        List {
            if let currentUser = userViewModel.user, !currentUser.bondRequestsSent.isEmpty {
                ForEach(Array(currentUser.bondRequestsSent.keys), id: \.self) { userId in
                    if let timestamp = currentUser.bondRequestsSent[userId] {
                        BondRequestRow(userId: userId, timestamp: timestamp, type: .sent)
                            .padding(.top, 4)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task {
                                        try? await bondViewModel.cancelBondRequest(from: userViewModel.user!.uid, to: userId)
                                        await refreshUserData()
                                    }
                                } label: {
                                    Label("Cancel", systemImage: "xmark.circle")
                                }
                                .tint(.red)
                            }
                    }
                }
            } else {
                EmptyStateView(
                    title: "No Sent Requests",
                    message: "You haven't sent any bond requests yet.",
                    systemImage: "paperplane"
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Helper Views
    
    private func tabButton(title: String, tag: Int) -> some View {
        Button {
            activeTab = tag
        } label: {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: activeTab == tag ? .semibold : .regular))
                    .foregroundColor(activeTab == tag ? Color("brandPrimary") : .gray)
                    .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(activeTab == tag ? Color("brandPrimary") : Color.clear)
                    .frame(height: 2)
            }
            .padding(.bottom)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Methods
    
    private func refreshUserData() async {
        await userViewModel.fetchUser(forceRefresh: true)
    }
}

// MARK: - Supporting Views

/// A reusable view for displaying user information
struct UserRow: View {
    let user: UserModel
    
    var body: some View {
        HStack(spacing: 12) {
            UserAvatar(username: user.username)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullname)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

/// A reusable view for displaying user avatars
struct UserAvatar: View {
    let username: String
    var size: CGFloat = 60
    
    var body: some View {
        Circle()
            .fill(Color("brandPrimary").opacity(0.2))
            .frame(width: size, height: size)
            .overlay(
                Text(String(username.prefix(1).uppercased()))
                    .font(.title3.bold())
                    .foregroundColor(Color("brandPrimary"))
            )
    }
}

/// A reusable view for empty states
struct EmptyStateView: View {
    let title: String
    var message: String? = nil
    let systemImage: String
    var withMessage: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(title)
                .font(.headline)
            
            if withMessage, let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
}

/// Enum to differentiate between received and sent requests
enum BondRequestType {
    case received
    case sent
}

/// A unified view for both received and sent bond requests
struct BondRequestRow: View {
    let userId: String
    let timestamp: Int
    let type: BondRequestType
    
    @State private var user: UserModel?
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 14)
                            .frame(width: 120)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                            .frame(width: 80)
                    }
                    
                    Spacer()
                }
                .redacted(reason: .placeholder)
            } else if let user = user {
                HStack(spacing: 12) {
                    NavigationLink(destination: ProfileView(userId: user.uid)) {
                        HStack(spacing: 12) {
                            UserAvatar(username: user.username)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullname)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("@\(user.username)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(formatTimestamp(timestamp))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                    }
                }
            } else {
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Unknown User")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("User not available")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .task {
            await loadUser()
        }
    }
    
    private func loadUser() async {
        isLoading = true
        defer { isLoading = false }
        
        let viewModel = UserViewModel()
        user = await viewModel.fetchSpecificUser(userId: userId)
    }
    
    private func formatTimestamp(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// Helper extension for timestamp formatting
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
