////
////  MomentViewModel.swift
////  Bondly
////
////  Created by Manish Agarwal on 17/05/25.
////

import SwiftUI
import Firebase

class MomentViewModel: ObservableObject {
    
    @Published var fetched_moments: [Moment] = []
    @Published var displaying_moments: [Moment] = []
    @Published var isLoading = false
    @Published var likedMomentIds: Set<String> = []

    
    private let pageSize = 10
    private var currentPage = 0
    private var allMomentIds: [String] = []

    init() {
        fetchAllMomentIds()
    }

    // Step 1: Get all moment IDs once (sorted by latest timestamp)
    func fetchAllMomentIds() {
        let ref = Database.database().reference().child("moments")
        ref.observeSingleEvent(of: .value) { snapshot in
            var tempIds: [(String, Double)] = []

            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let timestamp = dict["timestamp"] as? Double {
                    tempIds.append((snap.key, timestamp))
                }
            }

            // Sort descending by timestamp
            self.allMomentIds = tempIds.sorted(by: { $0.1 > $1.1 }).map { $0.0 }
            self.loadNextPage()
        }
    }

    // Step 2: Load moments using paginated IDs
    func loadNextPage() {
        guard !isLoading else { return }
        isLoading = true

        let start = currentPage * pageSize
        let end = min(start + pageSize, allMomentIds.count)

        guard start < end else {
            isLoading = false
            return
        }

        let batchIds = Array(allMomentIds[start..<end])
        let group = DispatchGroup()
        var newMoments: [Moment] = []

        for momentId in batchIds {
            group.enter()
            let ref = Database.database().reference().child("moments").child(momentId)
            ref.observeSingleEvent(of: .value) { snapshot in
                if let data = snapshot.value as? [String: Any],
                   let moment = Moment.fromDict(data, likedMomentIds: self.likedMomentIds) {
                    newMoments.append(moment)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.fetched_moments.append(contentsOf: newMoments)
            self.displaying_moments.append(contentsOf: newMoments)
            self.currentPage += 1
            self.isLoading = false
        }
    }

    func getIndex(moment: Moment) -> Int {
        displaying_moments.firstIndex(where: { $0.id == moment.id }) ?? 0
    }

    func shouldLoadMore(currentIndex: Int) -> Bool {
        let thresholdIndex = displaying_moments.count - 3
        return currentIndex >= thresholdIndex && !isLoading && displaying_moments.count < fetched_moments.count
    }
    @MainActor
    func refreshMoments() async {
        fetched_moments.removeAll()
        displaying_moments.removeAll()
        currentPage = 0
        fetchAllMomentIds()
    }

//    func fetchLikedMoments(for uid: String) {
//        let ref = Database.database().reference().child("users").child(uid).child("likedMomentIds")
//        ref.observeSingleEvent(of: .value) { snapshot in
//            if let array = snapshot.value as? [String] {
//                self.likedMomentIds = Set(array)
//            } else {
//                self.likedMomentIds = []
//            }
//        }
//    }
    
    func toggleLike(for moment: Moment, userId: String) {
        guard let index = displaying_moments.firstIndex(where: { $0.momentId == moment.momentId }) else { return }

        var updatedMoment = displaying_moments[index]
        let ref = Database.database().reference()

        if updatedMoment.isLikedByCurrentUser {
            updatedMoment.likes -= 1
            updatedMoment.isLikedByCurrentUser = false
            likedMomentIds.remove(moment.momentId)

            ref.child("moments").child(moment.momentId).child("likes").setValue(updatedMoment.likes)
            ref.child("users").child(userId).child("likedMomentIds").observeSingleEvent(of: .value) { snapshot in
                var current = snapshot.value as? [String] ?? []
                current.removeAll(where: { $0 == moment.momentId })
                ref.child("users").child(userId).child("likedMomentIds").setValue(current)
            }

        } else {
            updatedMoment.likes += 1
            updatedMoment.isLikedByCurrentUser = true
            likedMomentIds.insert(moment.momentId)

            ref.child("moments").child(moment.momentId).child("likes").setValue(updatedMoment.likes)
            ref.child("users").child(userId).child("likedMomentIds").observeSingleEvent(of: .value) { snapshot in
                var current = snapshot.value as? [String] ?? []
                if !current.contains(moment.momentId) {
                    current.append(moment.momentId)
                    ref.child("users").child(userId).child("likedMomentIds").setValue(current)
                }
            }
        }

        displaying_moments[index] = updatedMoment
    }
}


extension Moment {
    static func fromDict(_ dict: [String: Any], likedMomentIds: Set<String>) -> Moment? {
        guard let momentId = dict["momentId"] as? String,
              let createrId = dict["createrId"] as? String,
              let username = dict["username"] as? String,
              let fullname = dict["fullname"] as? String,
              let timestamp = dict["timestamp"] as? Double,
              let content = dict["content"] as? String,
              let tag = dict["tag"] as? String,
              let imageUrl = dict["imageUrl"] as? String,
              let likes = dict["likes"] as? Int else { return nil }

        return Moment(
            momentId: momentId,
            createrId: createrId,
            username: username,
            fullname: fullname,
            timestamp: timestamp,
            content: content,
            tag: tag,
            imageUrl: imageUrl,
            likes: likes,
            isLikedByCurrentUser: likedMomentIds.contains(momentId)
        )
    }
}
