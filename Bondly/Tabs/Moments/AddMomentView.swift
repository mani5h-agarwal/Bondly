//
//  AddMomentView.swift
//  Bondly
//
//  Created by Manish Agarwal on 17/05/25.
//
import SwiftUI
import PhotosUI

struct AddMomentView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isUploading = false
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var selectedTag: String = "Travel" // Default selected tag
    @State private var contentText: String = ""
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    
    @State private var selectedPickerItem: PhotosPickerItem? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    if let user = userViewModel.user {
                        VStack(alignment: .leading, spacing: 20) {
                            // User avatar and name section
                            HStack {
                                UserAvatar(username: user.fullname, size: 40)
                                
                                Text(user.username)
                                    .font(.headline)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Topic tag selector
                            VStack(alignment: .leading) {
                                Text("Moment Topic")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(allTags, id: \.self) { tag in
                                            TagButton(tag: tag, selectedTag: $selectedTag)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Content field
                            VStack(alignment: .leading) {
                                Text("Content")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextEditor(text: $contentText)
                                    .frame(minHeight: 150)
                                    .padding(4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .tint(Color("brandPrimary"))
                                    .overlay(
                                        Group {
                                            if contentText.isEmpty {
                                                Text("Share your \(selectedTag.lowercased()) moment...")
                                                    .foregroundColor(.gray)
                                                    .padding(.leading, 8)
                                                    .padding(.top, 8)
                                                    .allowsHitTesting(false)
                                            }
                                        }
                                    )
                            }
                            .padding(.horizontal)
                            VStack(alignment: .leading) {
                                Text("Image")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxHeight: 200)
                                        .clipped()
                                        .cornerRadius(8)
                                }
                                
                                PhotosPicker(
                                    selection: $selectedPickerItem,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    HStack {
                                        Image(systemName: "photo")
                                        Text(selectedImage == nil ? "Add Image" : "Change Image")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("brandPrimary").opacity(0.1))
                                    .foregroundColor(Color("brandPrimary"))
                                    .cornerRadius(8)
                                }
                                .tint(Color("brandPrimary"))
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    } else {
                        ProgressView("Loading user...")
                            .padding()
                    }
                }
                if isUploading {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                    ProgressView("Uploading...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .navigationTitle("New Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(Color("brandPrimary"))
                    .disabled(isUploading)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        guard let user = userViewModel.user else { return }
                        isUploading = true // start uploading
                        
                        MomentUploader.shared.uploadMoment(
                            content: contentText,
                            tag: selectedTag,
                            image: selectedImage,
                            user: user
                        ) { result in
                            DispatchQueue.main.async {
                                isUploading = false // stop uploading
                                switch result {
                                case .success:
                                    dismiss()
                                case .failure(let error):
                                    print("Upload failed: \(error.localizedDescription)")
                                    // show error alert if you want
                                }
                            }
                        }
                    }) {
                        Text("Post")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background((isUploading || contentText.isEmpty) ? Color.gray.opacity(0.3) : Color("brandPrimary"))
                            .foregroundColor(contentText.isEmpty ? .gray : .white)
                            .clipShape(Capsule())
                            .animation(.easeInOut(duration: 0.2), value: contentText)
                    }
                    .disabled(contentText.isEmpty || isUploading)
                }
            }
            .task(id: selectedPickerItem) {
                if let item = selectedPickerItem {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }
        }
    }
}


#Preview {
    AddMomentView()
}
