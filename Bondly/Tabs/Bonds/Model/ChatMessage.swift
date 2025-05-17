//////
//////  ChatMessage.swift
//////  Bondly
//////
//////  Created by Manish Agarwal on 17/05/25.
//////
//
import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "MessageEntity")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func saveMessage(_ message: Message) {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "messageId == %@", message.messageId)

        if (try? context.count(for: request)) ?? 0 == 0 {
            let entity = MessageEntity(context: context)
            entity.messageId = message.messageId
            entity.senderId = message.senderId
            entity.receiverId = message.receiverId
            entity.text = message.text
            entity.timestamp = message.timestamp
            saveContext()
        }
    }

    func fetchMessages(between user1: String, and user2: String) -> [Message] {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "(senderId == %@ AND receiverId == %@) OR (senderId == %@ AND receiverId == %@)", user1, user2, user2, user1)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        return (try? context.fetch(request).map {
            Message(messageId: $0.messageId ?? UUID().uuidString,
                    senderId: $0.senderId ?? "",
                    receiverId: $0.receiverId ?? "",
                    text: $0.text ?? "",
                    timestamp: $0.timestamp)
        }) ?? []
    }

    func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
//

struct Message: Codable, Identifiable, Equatable {
    var id: String { messageId }
    let messageId: String
    let senderId: String
    let receiverId: String
    let text: String
    let timestamp: Double
}

func getChatId(user1: String, user2: String) -> String {
    [user1, user2].sorted().joined(separator: "_")
}
//
//// MARK: - Send Message
func sendMessage(from senderId: String?, to receiverId: String, text: String) {
    guard let senderId = senderId else { return }
    let chatId = getChatId(user1: senderId, user2: receiverId)

    let messageRef = Database.database().reference()
        .child("chats")
        .child(chatId)
        .child("messages")
        .childByAutoId()

    let messageId = messageRef.key ?? UUID().uuidString
    let message = Message(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        timestamp: Date().timeIntervalSince1970
    )

    let messageData: [String: Any] = [
        "messageId": message.messageId,
        "senderId": message.senderId,
        "receiverId": message.receiverId,
        "text": message.text,
        "timestamp": message.timestamp
    ]

    messageRef.setValue(messageData) { error, _ in
        if error == nil {
            CoreDataManager.shared.saveMessage(message)
        }
    }
}
//
//// MARK: - ViewModel
///

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []

    private var messagesRef: DatabaseReference?

    @MainActor
    func observeMessages(with userId: String) {
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        let chatId = getChatId(user1: currentId, user2: userId)

        self.messages = CoreDataManager.shared.fetchMessages(between: currentId, and: userId)

        messagesRef = Database.database().reference()
            .child("chats")
            .child(chatId)
            .child("messages")

        messagesRef?.observe(.childAdded) { snapshot in
            guard let dict = snapshot.value as? [String: Any],
                  let data = try? JSONSerialization.data(withJSONObject: dict),
                  let message = try? JSONDecoder().decode(Message.self, from: data) else {
                return
            }

            DispatchQueue.main.async {
                if !self.messages.contains(where: { $0.messageId == message.messageId }) {
                    CoreDataManager.shared.saveMessage(message)
                    self.messages.append(message)
                }
            }
        }
    }

    deinit {
        messagesRef?.removeAllObservers()
    }
}
