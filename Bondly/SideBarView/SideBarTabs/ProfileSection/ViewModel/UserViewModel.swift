import Foundation
import FirebaseAuth
import FirebaseDatabase
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let cacheKey = "cachedUser"

    // MARK: - Fetch Current User
    func fetchUser(forceRefresh: Bool = false) async {
        isLoading = true
        errorMessage = nil

        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No authenticated user found"
            isLoading = false
            print("Error: No authenticated user found")
            return
        }

        print("Fetching current user with UID: \(uid), forceRefresh: \(forceRefresh)")
        
        // If we're not forcing a refresh, try to use the cached data first
        if !forceRefresh, let cachedUser = loadUserFromCacheSync() {
            self.user = cachedUser
            print("✅ Using cached user data while refreshing")
        }
        
        // Always fetch fresh data from Firebase
        await fetchAndCacheCurrentUser(uid: uid)
    }

    private func fetchAndCacheCurrentUser(uid: String) async {
        do {
            let ref = Database.database().reference().child("users").child(uid)
            let snapshot = try await ref.getData()

            guard let value = snapshot.value as? [String: Any] else {
                errorMessage = "User data not found or in unexpected format"
                isLoading = false
                print("Error: User data not found or in unexpected format")
                return
            }

            let userModel = try decodeUserFromFirebase(value, uid: uid)

            DispatchQueue.main.async {
                self.user = userModel
                self.saveUserToCache(userModel)
                self.isLoading = false
                print("✅ Successfully fetched and updated current user")
            }
        } catch {
            errorMessage = "Failed to fetch user: \(error.localizedDescription)"
            isLoading = false
            print("Error fetching user: \(error)")
            
            // Only load from cache if we don't already have a user
            if self.user == nil {
                loadUserFromCache()
            }
        }
    }

    // MARK: - Fetch Specific User
    func fetchSpecificUser(userId: String) async -> UserModel? {
        do {
            print("🔍 Fetching specific user with ID: \(userId)")
            let ref = Database.database().reference().child("users").child(userId)
            let snapshot = try await ref.getData()

            guard let value = snapshot.value as? [String: Any] else {
                print("❌ Specific user data not found or in unexpected format")
                return nil
            }

            let userModel = try decodeUserFromFirebase(value, uid: userId)
            print("✅ Successfully fetched specific user: \(userModel.username)")
            return userModel
        } catch {
            print("❌ Error fetching specific user:", error)
            return nil
        }
    }

    // MARK: - Decode User
    private func decodeUserFromFirebase(_ data: [String: Any], uid: String) throws -> UserModel {
        guard let username = data["username"] as? String else {
            throw NSError(domain: "UserViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing username"])
        }
        guard let email = data["email"] as? String else {
            throw NSError(domain: "UserViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing email"])
        }

        let fullname = data["fullname"] as? String ?? username
        let aboutMe = data["aboutMe"] as? String ?? ""
        let bondsCount = data["bondsCount"] as? Int ?? 0
        let interests = data["interests"] as? [String] ?? []
        
        // Ensure we properly handle these complex types
        var bondedUserIds: [String] = []
        if let bondedDict = data["bondedUserIds"] as? [String: Bool] {
            bondedUserIds = Array(bondedDict.keys)
        } else if let bondedArray = data["bondedUserIds"] as? [String] {
            bondedUserIds = bondedArray
        }
        
        let bondRequestsSent = data["bondRequestsSent"] as? [String: Int] ?? [:]
        let bondRequestsReceived = data["bondRequestsReceived"] as? [String: Int] ?? [:]
        let createdAt = data["createdAt"] as? String ?? ""

        return UserModel(
            uid: uid,
            username: username,
            fullname: fullname,
            email: email,
            aboutMe: aboutMe,
            bondsCount: bondsCount,
            interests: interests,
            bondedUserIds: bondedUserIds,
            bondRequestsSent: bondRequestsSent,
            bondRequestsReceived: bondRequestsReceived,
            createdAt: createdAt
        )
    }

    // MARK: - Update User Methods
    func updateAboutMe(_ aboutMe: String) async throws {
        guard let uid = user?.uid else { return }
        try await Database.database().reference()
            .child("users")
            .child(uid)
            .child("aboutMe")
            .setValue(aboutMe)
        user?.aboutMe = aboutMe
        if let user = user { saveUserToCache(user) }
    }

    func updateInterests(_ interests: [String]) async throws {
        guard let uid = user?.uid else { return }
        try await Database.database().reference()
            .child("users")
            .child(uid)
            .child("interests")
            .setValue(interests)
        user?.interests = interests
        if let user = user { saveUserToCache(user) }
    }

    func updateFullName(_ fullname: String) async throws {
        guard let uid = user?.uid else { return }
        try await Database.database().reference()
            .child("users")
            .child(uid)
            .child("fullname")
            .setValue(fullname)
        user?.fullname = fullname
        if let user = user { saveUserToCache(user) }
    }

    // MARK: - Cache Functions
    private func saveUserToCache(_ user: UserModel) {
        do {
            let data = try JSONEncoder().encode(user)
            UserDefaults.standard.set(data, forKey: cacheKey)
            print("✅ User cached successfully")
        } catch {
            print("❌ Failed to cache user:", error)
        }
    }

    private func loadUserFromCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
            print("⚠️ No cached user found")
            return
        }

        do {
            let cachedUser = try JSONDecoder().decode(UserModel.self, from: data)
            self.user = cachedUser
            print("✅ Loaded user from cache")
        } catch {
            print("❌ Failed to load cached user:", error)
        }
    }
    
    // Synchronous version that returns the user instead of setting the property
    private func loadUserFromCacheSync() -> UserModel? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(UserModel.self, from: data)
        } catch {
            print("❌ Failed to load cached user:", error)
            return nil
        }
    }

    func clearUserCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        print("🧹 Cleared cached user")
    }
}
