//
//  Post.swift
//  cOlive
//
//  Created by Iga Hupalo on 23/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage


class Post {
    let db: Firestore = Firestore.firestore()
    let storage: Storage = Storage.storage()
    var documentId: String?
    var listener: ListenerRegistration?

    var title: String
    var content: String?
    var date: Date?
    var author: User?
    var authorId: String
    var isActive: Bool
    var imageUrl: String?
    var image: UIImage?
    var comments: Comments?

    var dictionary: [String: Any] {
        let dateTimeInterval = Date().timeIntervalSince1970

        let dictionary: [String: Any?] = ["title": title, "content": content, "date": dateTimeInterval, "author_id": authorId, "image_url": imageUrl, "is_active": isActive]
        return dictionary.filter { $0.value != nil } .mapValues { $0! }
    }

    deinit {
        print("🟦 post deinit")
    }

    init(title: String, content: String?, date: Date, authorId: String, imageUrl: String?, image: UIImage?, isActive: Bool) {
        self.title = title
        self.content = content
        self.date = date
        self.authorId = authorId
        self.imageUrl = imageUrl
        self.isActive = isActive
        self.image = image
        self.comments = Comments()
    }

    convenience init(title: String, content: String?, authorId: String, image: UIImage?) {
        let date = Date()
        let isActive = true
        self.init(title: title, content: content, date: date, authorId: authorId, imageUrl: nil, image: image, isActive: isActive)
    }

    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let content = dictionary["content"] as! String? ?? nil
        let dateTimeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: dateTimeIntervalDate)
        let authorId = dictionary["author_id"] as! String? ?? ""
        let imageUrl = dictionary["image_url"] as! String? ?? nil
        let isActive = dictionary["is_active"] as! Bool? ?? true

        self.init(title: title, content: content, date: date, authorId: authorId, imageUrl: imageUrl, image: nil, isActive: isActive)
    }

    func setData(title: String, content: String?, date: Date, authorId: String, image: UIImage?, isActive: Bool) {
        self.title = title
        self.content = content
        self.date = date
        self.authorId = authorId
        self.image = image
        self.isActive = isActive
    }


    func setData(dictionary: [String: Any]) {
        self.title = dictionary["title"] as! String? ?? ""
        self.content = dictionary["content"] as! String? ?? nil
        let dateTimeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        self.date = Date(timeIntervalSince1970: dateTimeIntervalDate)
        self.authorId = dictionary["author_id"] as! String? ?? ""
        self.imageUrl = dictionary["image_url"] as! String? ?? nil
        self.imageUrl = dictionary["image_url"] as! String? ?? nil
        self.isActive = dictionary["is_active"] as! Bool? ?? true
    }

    // MARK: Database functions

    func fetchComments(flat: Flat, completion: @escaping () -> ()) {
        self.comments = Comments()

        guard let postId = self.documentId else {
            completion()
            return
        }
        self.comments?.fetch(flat: flat, postId: postId) {
            completion()
        }
    }

    func save(flatId: String?, completion: @escaping () -> ()) {

        guard let flatId = flatId else {
            print("🔴 DATABASE ERROR: updating post \(String(describing: documentId))")
            return completion()
        }
        if let documentId = documentId {
            let ref = db.collection("flats").document(flatId).collection("posts").document(documentId)
            ref.setData(self.dictionary) { error in
                if let error = error {
                    print("🔴 ERROR: Updating post \(documentId) \(error)")
                    completion()
                }

                if self.image != nil {
                    self.saveImage(flatId: flatId) { (_) in
                        print("🟢 DATABASE: Updated post \(String(describing: documentId))")
                        completion()
                    }
                } else {
                    print("🟢 DATABASE: Updated post \(String(describing: documentId))")
                    completion()
                }
            }
        } else {
            self.date = Date()
            let ref = db.collection("flats").document(flatId).collection("posts").document()
            ref.setData(self.dictionary) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: Creating post \(error)")
                    completion()
                }
                self.documentId = ref.documentID
                if self.image != nil {
                    self.saveImage(flatId: flatId) { (_) in
                        print("🟢 DATABASE: Created post with image \(String(describing: self.documentId))")
                        completion()
                    }
                } else {
                    print("🟢 DATABASE: Created post \(String(describing: self.documentId))")
                    completion()
                }
            }
        }
    }

    func getImageData(ref: StorageReference, completion: @escaping (Data?) -> ()) {
        ref.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("🔴 DATABASE ERROR: Downloading user image \(error!.localizedDescription)")
                completion(nil)
            }
            guard let data = data else {
                print("🔴 DATABASE ERROR: Downloading user image")
                completion(nil)
                return
            }
            completion(data)
        }
    }

    func saveImage(flatId: String, completion: @escaping (Bool) -> ()) {
        if let imageData = self.image?.jpegData(compressionQuality: 0.5) {
            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image.jpeg"
            let storageRef = storage.reference().child("flats").child(flatId).child("posts").child(self.documentId!)
            let uploadTask = storageRef.putData(imageData, metadata: uploadMetadata) { (metadata, error) in
                if let error = error { print("🔴 ERROR: Uploading image \(error.localizedDescription)") }
            }
            uploadTask.observe(.success) { (snapshot) in
                print("🟢 DATABASE: Added post image to storage")
                let ref = self.db.collection("flats").document(flatId).collection("posts").document(self.documentId!)
                storageRef.downloadURL { (imageUrl, error) in
                    if let error = error {
                        print("🔴 DATABASE ERROR: Downloading usepostr image \(self.documentId!) \(error.localizedDescription)")
                        completion(false)
                    }
                    guard let imageUrl = imageUrl?.absoluteString else {
                        print("🔴 DATABASE ERROR: Downloading post image - no image \(self.documentId!)")
                        completion(false)
                        return
                    }
                    ref.updateData(["image_url": imageUrl]) { (error) in
                        if let error = error {
                            print("🔴 DATABASE ERROR: Adding post image \(self.documentId!) \(error.localizedDescription)")
                            completion(false)
                        }
                        self.imageUrl = imageUrl
                        print("🟢 DATABASE: Updated post \(String(describing: self.documentId!))")
                        completion(true)
                    }
                }
            }
            uploadTask.observe(.failure) { (snapshot) in
                if let error = snapshot.error {
                    print("🔴 DATABASE ERROR: Adding usepostr image to storage \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }

    func detachCommentListener() {
        self.comments?.detachListeners()
    }
}
