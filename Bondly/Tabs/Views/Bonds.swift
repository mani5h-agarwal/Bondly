//
//  Bonds.swift
//  Bondly
//
//  Created by Manish Agarwal on 15/05/25.
//

import SwiftUI


struct Bonds: View {
    @State private var selectedChatIndex: ChatItem? = nil
    @State var text: String = ""
    var body: some View {
        ScrollView {
            ForEach(0..<30, id: \.self) { index in
                Button(action: {
                    selectedChatIndex = ChatItem(id: index)
                }) {
                    Text("Chat \(index + 1)")
                        .frame(width: 375, height: 60)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.vertical, 4)
            }
            Spacer()
                .frame(height: 100)
        }
        .searchable(text: $text, prompt:"Search Bonds")
        .fullScreenCover(item: $selectedChatIndex) { chatItem in
            ChatDetailView(chatIndex: chatItem.id)
        }
    }
}

struct ChatItem: Identifiable {
    let id: Int
}
struct ChatDetailView: View {
    let chatIndex: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("Chat Details for Chat \(chatIndex + 1)")
                Button("Back") {
                    dismiss()
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle("Chat \(chatIndex + 1)")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}
