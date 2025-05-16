//
//  ChatDetailView.swift
//  Bondly
//
//  Created by Manish Agarwal on 16/05/25.
//

import SwiftUI

struct ChatItem: Identifiable {
    let id: String
}

struct ChatDetailView: View {
    let userId: String
    @Environment(\.dismiss) var dismiss
    @State private var userPreview: UserPreviewModel?
    @State private var isLoading = true
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading chat...")
                } else if let user = userPreview {
                    chatInterface(with: user)
                } else {
                    Text("Couldn't load user information")
                }
            }
            .navigationTitle(userPreview?.fullname ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView(userId: userId)) {
                        if let user = userPreview {
                            NavigationLink(destination: ProfileView(userId: userId)) {
                                UserAvatar(username: user.username, size: 30)
                            }
                        } else {
                            Image(systemName: "person.circle")
                                .foregroundColor(Color("brandPrimary"))
                        }
                    }
                }
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
                await loadUserData()
            }
        }
    }
    
    private func chatInterface(with user: UserPreviewModel) -> some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(1...5, id: \.self) { i in
                        HStack {
                            if i % 2 == 0 {
                                Spacer()
                                Text("This is where your message w o u l d a p p e a r")
                                    .padding()
                                    .background(Color("brandPrimary").opacity(0.2))
                                    .foregroundColor(.primary)
                                    .clipShape(
                                        .rect(
                                            topLeadingRadius: 12,
                                            bottomLeadingRadius: 12,
                                            bottomTrailingRadius: 0,
                                            topTrailingRadius: 12
                                        )
                                    )
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .trailing)
                            } else {
                                Text("This is where \(user.fullname)'s message would appear")
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .clipShape(
                                        .rect(
                                            topLeadingRadius: 0,
                                            bottomLeadingRadius: 12,
                                            bottomTrailingRadius: 12,
                                            topTrailingRadius: 12
                                        )
                                    )
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            MessageField()
        }
    }
    
    private func loadUserData() async {
        isLoading = true
        userPreview = await userViewModel.fetchUserPreview(userId: userId)
        isLoading = false
    }
}



