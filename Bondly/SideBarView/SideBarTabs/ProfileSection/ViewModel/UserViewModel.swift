
import Foundation
import FirebaseAuth
import FirebaseDatabase
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Cache keys
    private let fullUserCacheKey = "cachedUser"
    private let userPreviewsCacheKey = "cachedUserPreviews"
    
    // In-memory cache for user previews to reduce firebase calls
    private var userPreviewsCache: [String: UserPreviewModel] = [:]

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

            let userModel = try UserModel.fromFirebaseData(value, uid: uid)

            DispatchQueue.main.async {
                self.user = userModel
                self.saveUserToCache(userModel)
                
                // Also cache the preview version for quick access
                self.cacheUserPreview(userModel.preview)
                
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

    // MARK: - Fetch User Preview
    func fetchUserPreview(userId: String) async -> UserPreviewModel? {
        // Check in-memory cache first
        if let cachedPreview = userPreviewsCache[userId] {
            print("✅ Using in-memory cached preview for user: \(userId)")
            return cachedPreview
        }
        
        // Check UserDefaults cache next
        if let cachedPreviews = loadUserPreviewsFromCache(),
           let cachedPreview = cachedPreviews[userId] {
            // Update in-memory cache and return
            userPreviewsCache[userId] = cachedPreview
            print("✅ Using UserDefaults cached preview for user: \(userId)")
            return cachedPreview
        }
        
        // If not in cache, fetch from Firebase
        do {
            print("🔍 Fetching user preview for ID: \(userId)")
            let ref = Database.database().reference().child("users").child(userId)
            
            // Only fetch the fields we need for a preview
            let snapshot = try await ref.child("username").getData()
            let fullnameSnapshot = try await ref.child("fullname").getData()
            
            guard let username = snapshot.value as? String else {
                print("❌ Username not found")
                return nil
            }
            
            let fullname = fullnameSnapshot.value as? String ?? username
            
            let userPreview = UserPreviewModel(uid: userId, username: username, fullname: fullname)
            
            // Cache the preview
            cacheUserPreview(userPreview)
            
            print("✅ Successfully fetched user preview for: \(username)")
            return userPreview
        } catch {
            print("❌ Error fetching user preview:", error)
            return nil
        }
    }

    // MARK: - Fetch Specific User (full details)
    func fetchSpecificUser(userId: String) async -> UserModel? {
        do {
            print("🔍 Fetching specific user with ID: \(userId)")
            let ref = Database.database().reference().child("users").child(userId)
            let snapshot = try await ref.getData()

            guard let value = snapshot.value as? [String: Any] else {
                print("❌ Specific user data not found or in unexpected format")
                return nil
            }

            let userModel = try UserModel.fromFirebaseData(value, uid: userId)
            
            // Cache the preview for future use
            cacheUserPreview(userModel.preview)
            
            print("✅ Successfully fetched specific user: \(userModel.username)")
            return userModel
        } catch {
            print("❌ Error fetching specific user:", error)
            return nil
        }
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
        
        // Update both full user cache and preview cache
        if let user = user {
            saveUserToCache(user)
            cacheUserPreview(user.preview)
        }
    }

    // MARK: - Full User Cache Functions
    private func saveUserToCache(_ user: UserModel) {
        do {
            let data = try JSONEncoder().encode(user)
            UserDefaults.standard.set(data, forKey: fullUserCacheKey)
            print("✅ User cached successfully")
        } catch {
            print("❌ Failed to cache user:", error)
        }
    }

    private func loadUserFromCache() {
        guard let data = UserDefaults.standard.data(forKey: fullUserCacheKey) else {
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
        guard let data = UserDefaults.standard.data(forKey: fullUserCacheKey) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(UserModel.self, from: data)
        } catch {
            print("❌ Failed to load cached user:", error)
            return nil
        }
    }
    
    // MARK: - User Preview Cache Functions
    private func cacheUserPreview(_ preview: UserPreviewModel) {
        // Update in-memory cache
        userPreviewsCache[preview.uid] = preview
        
        // Update UserDefaults cache
        var cachedPreviews = loadUserPreviewsFromCache() ?? [:]
        cachedPreviews[preview.uid] = preview
        
        do {
            let data = try JSONEncoder().encode(cachedPreviews)
            UserDefaults.standard.set(data, forKey: userPreviewsCacheKey)
            print("✅ User preview cached successfully")
        } catch {
            print("❌ Failed to cache user preview:", error)
        }
    }
    
    private func loadUserPreviewsFromCache() -> [String: UserPreviewModel]? {
        guard let data = UserDefaults.standard.data(forKey: userPreviewsCacheKey) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode([String: UserPreviewModel].self, from: data)
        } catch {
            print("❌ Failed to load cached user previews:", error)
            return nil
        }
    }

    func clearAllCaches() {
        UserDefaults.standard.removeObject(forKey: fullUserCacheKey)
        UserDefaults.standard.removeObject(forKey: userPreviewsCacheKey)
        userPreviewsCache.removeAll()
        print("🧹 Cleared all user caches")
    }
    
//    func clearUserCache() {
//        UserDefaults.standard.removeObject(forKey: fullUserCacheKey)
//        print("🧹 Cleared cached user")
//    }
}
