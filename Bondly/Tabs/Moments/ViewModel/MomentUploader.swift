////
////  MomentUploader.swift
////  Bondly
////
////  Created by Manish Agarwal on 17/05/25.
////
import Foundation
import UIKit
import Firebase
import Cloudinary


class MomentUploader {
    static let shared = MomentUploader()

    private init() {}

    func uploadMoment(content: String, tag: String, image: UIImage?, user: UserModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let momentId = UUID().uuidString
        let timestamp = Date().timeIntervalSince1970

        if let image = image,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            CloudinaryManager.shared.uploadImage(imageData: imageData) { result in
                switch result {
                case .success(let imageUrl):
                    self.uploadMomentToDatabase(momentId: momentId, content: content, tag: tag, imageUrl: imageUrl, user: user, timestamp: timestamp, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            self.uploadMomentToDatabase(momentId: momentId, content: content, tag: tag, imageUrl: "", user: user, timestamp: timestamp, completion: completion)
        }
    }

    private func uploadMomentToDatabase(momentId: String, content: String, tag: String, imageUrl: String, user: UserModel, timestamp: Double, completion: @escaping (Result<Void, Error>) -> Void) {
        let moment: [String: Any] = [
            "momentId": momentId,
            "createrId": user.uid,
            "username": user.username,
            "fullname": user.fullname,
            "timestamp": timestamp,
            "content": content,
            "tag": tag,
            "imageUrl": imageUrl,
            "likes": 0
        ]

        let momentsRef = Database.database().reference().child("moments").child(momentId)
        let userMomentsRef = Database.database().reference().child("users").child(user.uid).child("momentIds")

        momentsRef.setValue(moment) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                // Append the momentId to the user's momentIds array
                userMomentsRef.observeSingleEvent(of: .value) { snapshot in
                    var momentIds = snapshot.value as? [String] ?? []
                    momentIds.append(momentId)

                    userMomentsRef.setValue(momentIds) { error, _ in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
}


class CloudinaryManager {
    static let shared = CloudinaryManager()

    private let cloudinary: CLDCloudinary

    private init() {
        let config = CLDConfiguration(cloudName: "dsbmufakb",
                                      apiKey: "228482466293893",
                                      apiSecret: "idqHlHxcgsb-yz_YkXfOYa2_q3Q")
        self.cloudinary = CLDCloudinary(configuration: config)
    }

    func uploadImage(imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let params = CLDUploadRequestParams()
        cloudinary.createUploader().upload(data: imageData, uploadPreset: "unsigned_preset", params: params, progress: nil) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let result = result, let url = result.secureUrl {
                completion(.success(url))
            }
        }
    }
}
