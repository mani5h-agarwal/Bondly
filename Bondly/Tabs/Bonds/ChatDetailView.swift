////////
////////  ChatDetailView.swift
////////  Bondly
////////
////////  Created by Manish Agarwal on 16/05/25.
////////
//////
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
    @StateObject private var chatViewModel = ChatViewModel()

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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color("brandPrimary"))
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
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
            .task {
                await loadUserData()
            }
        }
    }

    private func chatInterface(with user: UserPreviewModel) -> some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(chatViewModel.messages) { msg in
                            ChatBubble(
                                message: msg,
                                isCurrentUser: msg.senderId == userViewModel.user?.uid
                            )
                            .id(msg.id)
                        }
                    }
                }
                .onChange(of: chatViewModel.messages.count) {
                    if let lastId = chatViewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    if let lastId = chatViewModel.messages.last?.id {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            MessageField(onSend: { text in
                sendMessage(from: userViewModel.user?.uid, to: userId, text: text)
            })
        }
        .onAppear {
            chatViewModel.observeMessages(with: userId)
        }
    }

    private func loadUserData() async {
        isLoading = true
        userPreview = await userViewModel.fetchUserPreview(userId: userId)
        isLoading = false
    }
}

struct ChatBubble: View {
    let message: Message
    let isCurrentUser: Bool

    var body: some View {
        HStack(alignment: .bottom) {
            if isCurrentUser { Spacer() }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding()
                    .background(isCurrentUser ? Color("brandPrimary").opacity(0.2) : Color.gray.opacity(0.2))
                    .clipShape(
                        .rect(
                            topLeadingRadius: isCurrentUser ? 12 : 0,
                            bottomLeadingRadius: 12,
                            bottomTrailingRadius: isCurrentUser ? 0 : 12,
                            topTrailingRadius: 12
                        )
                    )

                Text(timeString(from: message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }

            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
    }

    private func timeString(from timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
