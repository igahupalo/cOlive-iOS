//
//  Flat.swift
//  cOlive
//
//  Created by Iga Hupalo on 18/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class Flat {
    let db: Firestore = Firestore.firestore()
    let storage: Storage = Storage.storage()
    var documentId: String?

    var name: String
    var ownerId: String
    var isActive: Bool
    var image: UIImage?
    var imageUrl: String?

    var dictionary: [String: Any] {
        return ["name": name, "owner_id": ownerId, "is_active": isActive]
    }

    // AddFlatViewController
    init(name: String, ownerId: String, isActive: Bool, image: UIImage?) {
        self.name = name
        self.ownerId = ownerId
        self.isActive = isActive
        self.image = image
    }

    // FlatTableViewCell
    convenience init(documentId: String) {
        self.init(name: "", ownerId: "", isActive: true, image: nil)
        self.documentId = documentId
    }

//    convenience init(dictionary: [String: Any]) {
//        let name = dictionary["name"] as! String? ?? ""
//        let ownerId = dictionary["ownerId"] as! String? ?? ""
//        let isActive = dictionary["isActive"] as! Bool? ?? true
//        let imageUrl = dictionary["image_url"] as! String? ?? nil
//
//        self.init(name: name, ownerId: ownerId, isActive: isActive)
//        self.imageUrl = imageUrl
//    }

    func fetchData(completion: @escaping () -> ()) {
        guard let documentId = documentId else {
            print("🔴 ERROR: Fetching flat as no flat id was given")
            return completion()
        }
        db.collection("flats").document(documentId).addSnapshotListener { documentSnapshot, error in
            guard error == nil else {
                print("🔴 ERROR: Adding flat snapshot listener")
                completion()
                return
            }
            if let document = documentSnapshot {
                if let data = document.data() {
                    self.name = data["name"] as? String ?? ""
                    self.ownerId = data["owner_id"] as? String ?? ""
                    self.isActive = data["is_active"] as? Bool ?? true
                }
            }
            completion()
        }
    }

    func saveData(completion: @escaping (Bool) -> ()) {
        if let documentId = documentId {
            let ref = db.collection("flats").document(documentId)
            ref.setData(self.dictionary) { (error) in
                if let error = error {
                    print("🔴 DATABASE ERROR: Updating flat \(documentId) \(error.localizedDescription)")
                    completion(false)
                }
                print("🟢 DATABASE: Updated flat \(String(describing: documentId))")
            }
        } else {
            let ref = db.collection("flats").document()
            ref.setData(self.dictionary) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: Creating flat \(error.localizedDescription)")
                    completion(false)
                }
            }
            self.documentId = ref.documentID
            print("🟢 DATABASE: Created flat \(String(describing: documentId))")
        }

        // A new photo was picked.
        if let imageData = self.image?.jpegData(compressionQuality: 0.5) {
            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image.jpeg"
            let storageRef = storage.reference().child("flats").child(self.documentId!).child("thumbnail").child("image")
            let uploadTask = storageRef.putData(imageData, metadata: uploadMetadata) { (metadata, error) in
                if let error = error { print("🔴 ERROR: uploading image \(error.localizedDescription)") }
            }
            uploadTask.observe(.success) { (snapshot) in
                print("🟢 DATABASE: Added flat image to storage")
                let ref = self.db.collection("flats").document(self.documentId!)
                storageRef.downloadURL { (imageUrl, error) in
                    if let error = error {
                        print("🔴 DATABASE ERROR: Downloading flat image \(self.documentId!) \(error.localizedDescription)")
                        completion(false)
                    }
                    guard let imageUrl = imageUrl else {
                        print("🔴 DATABASE ERROR: Downloading flat image - no image \(self.documentId!)")
                        completion(false)
                        return
                    }
                    ref.updateData(["image_url": imageUrl.absoluteString]) { (error) in
                        if let error = error {
                            print("🔴 DATABASE ERROR: Adding flat image \(self.documentId!) \(error.localizedDescription)")
                            completion(false)
                        }
                        print("🟢 DATABASE: Updated flat \(String(describing: self.documentId!))")
                    }
                    completion(true)
                }
            }
            uploadTask.observe(.failure) { (snapshot) in
                if let error = snapshot.error {
                    print("🔴 DATABASE ERROR: Adding flat image to storage \(error.localizedDescription)")
                    completion(false)
                }
            }
        }

//        No  photo added
        
//        completion(true)
    }

    func delete() {
        if let documentId = documentId {
            let ref = db.collection("flats").document(documentId)
            ref.delete() { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: deleting flat \(documentId) \(error.localizedDescription)")
                    return
                }
                print("🟢 DATABASE: Deleted flat \(String(describing: documentId))")
            }
        }
    }
}
