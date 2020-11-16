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
    var listener: ListenerRegistration?

    var name: String
    var ownerId: String
    var isActive: Bool
    var imageUrl: String?
    var image: UIImage?
    var members: Members

    var dictionary: [String: Any] {
        let dictionary = ["name": name, "owner_id": ownerId, "is_active": isActive, "image_url": imageUrl] as [String: Any?]
        return dictionary.filter { $0.value != nil } .mapValues { $0! }
    }

    deinit {
        print("🟦 flat deinit")
    }

    init(name: String, ownerId: String, isActive: Bool, image: UIImage?) {
        self.name = name
        self.ownerId = ownerId
        self.isActive = isActive
        self.image = image
        self.members = Members()
    }

    convenience init(documentId: String?) {
        self.init(name: "", ownerId: "", isActive: true, image: nil)
        self.documentId = documentId
    }

    func fetchMembers(currentUser: User, completion: @escaping () -> ()) {
        self.members.fetch(flat: self, currentUser: currentUser) {
            completion()
        }
    }

    func fetch(completion: @escaping () -> ()) {
        guard documentId != nil else {
            print("🔴 ERROR: Fetching flat as no flat id was given")
            return completion()
        }
        self.listener = db.collection("flats").document(documentId!).addSnapshotListener { documentSnapshot, error in
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
                    self.imageUrl = data["image_url"] as! String?

                    completion()


//  TO JEST ZDJECIE
//                    if let imageUrl = self.imageUrl {
//                        let ref = self.storage.reference(forURL: imageUrl)
//                        self.getImageData(ref: ref) { (data) in
//                            guard data != nil else {
//                                completion()
//                                return
//                            }
//                            let image = UIImage(data: data!)
//                            self.image = image
//
//                        }
//                    }


                }
            }
        }
    }


    func save(completion: @escaping (Bool) -> ()) {
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

        let dispatchGroup = DispatchGroup()

        // No image was choosen, set random image.
        if self.image == nil {
            dispatchGroup.enter()
            self.setRandomImage { success in
                guard success else {
                    completion(false)
                    return
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.saveImage { (success) in
                guard success else {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }

    func setRandomImage(completion: @escaping (Bool) -> ()) {
        storage.reference().child("APP_ASSETS").listAll { (list, error) in
            if let error = error {
                print("🔴 DATABASE ERROR: Fetching images references for flat \(error.localizedDescription)")
                completion(false)
            }
            let randomImageRef = list.items.randomElement()

            guard randomImageRef != nil else {
                print("🔴 DATABASE ERROR: Fetching random image reference for flat")
                completion(false)
                return
            }

            self.getImageData(ref: randomImageRef!) { (data) in
                guard data != nil else {
                    completion(false)
                    return
                }
                let image = UIImage(data: data!)
                self.image = image
                completion(true)
            }
        }
    }

    func getImageData(ref: StorageReference, completion: @escaping (Data?) -> ()) {
        ref.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("🔴 DATABASE ERROR: Downloading flat image \(error!.localizedDescription)")
                completion(nil)
            }
            guard let data = data else {
                print("🔴 DATABASE ERROR: Downloading flat image")
                completion(nil)
                return
            }
            completion(data)
        }
    }

    func saveImage(completion: @escaping (Bool) -> ()) {
        if let imageData = self.image?.jpegData(compressionQuality: 0.5) {
            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image.jpeg"
            let storageRef = storage.reference().child("flats").child(self.documentId!).child("thumbnail").child("image")
            let uploadTask = storageRef.putData(imageData, metadata: uploadMetadata) { (metadata, error) in
                if let error = error { print("🔴 ERROR: Uploading image \(error.localizedDescription)") }
            }
            uploadTask.observe(.success) { (snapshot) in
                print("🟢 DATABASE: Added flat image to storage")
                let ref = self.db.collection("flats").document(self.documentId!)
                storageRef.downloadURL { (imageUrl, error) in
                    if let error = error {
                        print("🔴 DATABASE ERROR: Downloading flat image \(self.documentId!) \(error.localizedDescription)")
                        completion(false)
                    }
                    guard let imageUrl = imageUrl?.absoluteString else {
                        print("🔴 DATABASE ERROR: Downloading flat image - no image \(self.documentId!)")
                        completion(false)
                        return
                    }
                    ref.updateData(["image_url": imageUrl]) { (error) in
                        if let error = error {
                            print("🔴 DATABASE ERROR: Adding flat image \(self.documentId!) \(error.localizedDescription)")
                            completion(false)
                        }
                        self.imageUrl = imageUrl
                        print("🟢 DATABASE: Updated flat \(String(describing: self.documentId!))")
                        completion(true)
                    }
                }
            }
            uploadTask.observe(.failure) { (snapshot) in
                if let error = snapshot.error {
                    print("🔴 DATABASE ERROR: Adding flat image to storage \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }

    func create(owner user: User, completion: @escaping (Bool) -> ()) {
        // Save flat.
        self.save { flatSuccess in
            // Create membership.
            guard flatSuccess else {
                print("🔴 ERROR: No flat to assign to the new membership.")
                completion(false)
                return
            }
            guard let documentId = self.documentId else {
                print("🔴 ERROR: No flat id to assign to the new membership.")
                completion(false)
                return
            }

            // Create membership
            let membership = Membership(flatId: documentId, lastUsed: Date(), type: Membership.MembershipType.owner)

            membership.save(user: user) { membershipSuccess in
                guard membershipSuccess else {
                    print("🔴 ERROR: No membership created.")
                    completion(false)
                    self.delete()
                    return
                }

                // Create member
                guard let userId = user.documentId else {
                    print("🔴 ERROR: No membership created.")
                    completion(false)
                    membership.delete(user: user)
                    self.delete()
                    return
                }

                let member = Member(userId: userId, isActive: true)

                member.save(flat: self) { (memberSuccess) in
                    guard memberSuccess else {
                        print("🔴 ERROR: No member created.")
                        completion(false)
                        membership.delete(user: user)
                        self.delete()
                        return
                    }

                    completion(true)
                }
            }
        }
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

    func detachListeners() {
        if let flatListener = self.listener {
            print("🔷 Listener detached - flat \(self.name)")
            flatListener.remove()
        }
    }
}
