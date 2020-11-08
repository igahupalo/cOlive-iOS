//
//  User.swift
//  cOlive
//
//  Created by Iga Hupalo on 16/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class User: UserProtocol {
    let db: Firestore = Firestore.firestore()
    let storage: Storage = Storage.storage()
    var documentId: String?
    var listener: ListenerRegistration?

    var uid: String
    var username: String
    var email: String
    var firstName: String?
    var lastName: String?
    var membershipId: String?
    var membership: Membership?
    var imageUrl: String?
    var image: UIImage? {
        didSet {
            self.imageUrl = nil
        }
    }

    var dictionary: [String: Any] {
        let dictionary =  ["uid": uid, "username": username, "email": email, "first_name": firstName, "last_name": lastName, "image_url": imageUrl, "membership_id": membershipId]
        return dictionary.filter { $0.value != nil } .mapValues { $0! }
    }

    init(uid: String, username: String, email: String, firstName: String?, lastName: String?, imageUrl: String?, membershipId: String?) {
        self.uid = uid
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.imageUrl = imageUrl
        self.membershipId = membershipId
        self.membership = Membership(documentId: membershipId ?? "")
    }

    convenience init() {
        self.init(uid: "", username: "", email: "", firstName: nil, lastName: nil, imageUrl: nil, membershipId: nil)
    }

    convenience init(uid: String, username: String, email: String) {
        let uid = uid
        let username = username
        let email = email

        self.init(uid: uid, username: username, email: email, firstName: nil, lastName: nil, imageUrl: nil, membershipId: nil)
    }

    convenience init(dictionary: [String: Any]) {
        let uid = dictionary["uid"] as! String? ?? ""
        let username = dictionary["username"] as! String? ?? ""
        let email = dictionary["email"] as! String? ?? ""
        let firstName = dictionary["first_name"] as! String?
        let lastName = dictionary["last_name"] as! String?
        let imageUrl = dictionary["image_url"] as! String?
        let membershipId = dictionary["membership_id"] as! String?

        self.init(uid: uid, username: username, email: email, firstName: firstName, lastName: lastName, imageUrl: imageUrl, membershipId: membershipId)
    }

    func setData(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as! String? ?? ""
        self.username = dictionary["username"] as! String? ?? ""
        self.email = dictionary["email"] as! String? ?? ""
        self.firstName = dictionary["first_name"] as! String?
        self.lastName = dictionary["last_name"] as! String?
        self.imageUrl = dictionary["image_url"] as! String?
        self.membershipId = dictionary["membership_id"] as! String?
    }

    // MARK: Firebase functions.

    func setMembership(membershipId: String, completion: @escaping () -> ()) {
        if let membership = self.membership {
            membership.detachListeners()
        }
        self.membership = Membership(documentId: membershipId)
        self.membership?.fetch(user: self) {
            self.save { success in
                guard success else {
                    print("🔴 DATABASE ERROR: Setting user's membership")
                    completion()
                    return
                }
                print("🟢 DATABASE: Set user's membership")
                completion()
            }
        }

    }

    func fetchMembership(completion: @escaping () -> ()) {
        if self.membership?.documentId == "" { self.membership?.documentId = self.membershipId }
        self.membership?.fetch(user: self) {
            completion()
        }
    }

    func fetchCurrent(completion: @escaping () -> ()) {
        if let currentUser = Auth.auth().currentUser {
            self.listener = db.collection("users").whereField("uid", isEqualTo: currentUser.uid).limit(to: 1).addSnapshotListener { documentSnapshots, error in
                guard error == nil else {
                    print("🔴 DATABASE ERROR: Fetching current user \(String(describing: error?.localizedDescription))")
                    return
                }

                guard documentSnapshots != nil else {
                    print("🔴 DATABASE ERROR: Fetching current user as document does not exist.")
                    return
                }

                guard documentSnapshots!.documents.count == 1 else {
                    print("🔴 DATABASE ERROR: Fetching current user as more than one current user.")
                    return
                }

                let document = documentSnapshots!.documents[0]
                self.setData(dictionary: document.data())
                self.documentId = document.documentID

                if let imageUrl = self.imageUrl {
                    let ref = self.storage.reference(forURL: imageUrl)
                    self.getImageData(ref: ref) { (data) in
                        guard data != nil else {
                            completion()
                            return
                        }
                        let image = UIImage(data: data!)
                        self.image = image
                        self.fetchMembership {
                            completion()
                        }
                    }
                }

            }
        }
    }

    func fetch(completion: @escaping () -> ()) {
        guard documentId != nil else {
            print("🔴 ERROR: Fetching user as no user id was given")
            return completion()
        }
        self.listener = db.collection("users").document(documentId!).addSnapshotListener { documentSnapshot, error in
            guard error == nil else {
                print("🔴 ERROR: Adding user snapshot listener")
                completion()
                return
            }
            if let document = documentSnapshot {
                if let data = document.data() {
                    self.setData(dictionary: data)
                    if let imageUrl = self.imageUrl {
                        let ref = self.storage.reference(forURL: imageUrl)
                        self.getImageData(ref: ref) { (data) in
                            guard data != nil else {
                                completion()
                                return
                            }
                            let image = UIImage(data: data!)
                            self.image = image
                            completion()
                        }
                    }
                }
            }
        }
    }

    func save(completion: @escaping (Bool) -> ()) {
        if let documentId = self.documentId {
            let ref = db.collection("users").document(documentId)
            ref.setData(self.dictionary) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: updating user \(documentId) \(error.localizedDescription)")
                    completion(false)
                }
                print("🟢 DATABASE: Updated user \(String(describing: documentId))")
                completion(true)
            }
        } else {
            let ref = db.collection("users").document()
            ref.setData(self.dictionary) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: Creating user \(error.localizedDescription)")
                    completion(false)
                }
                self.documentId = ref.documentID
                self.setRandomImage { (settingSuccess) in
                    guard settingSuccess else {
                        print("🔴 DATABASE ERROR: Setting random user image")
                        completion(false)
                        return
                    }
                    self.saveImage { (savingSuccess) in
                        guard savingSuccess else {
                            print("🔴 DATABASE ERROR: Saving random user image")
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
                print("🟢 DATABASE: Created user \(String(describing: self.documentId))")
                completion(true)
            }
        }
    }

    func setRandomImage(completion: @escaping (Bool) -> ()) {
        storage.reference().child("APP_ASSETS").listAll { (list, error) in
            if let error = error {
                print("🔴 DATABASE ERROR: Fetching images references for user \(error.localizedDescription)")
                completion(false)
            }
            let randomImageRef = list.items.randomElement()

            guard randomImageRef != nil else {
                print("🔴 DATABASE ERROR: Fetching random image reference for user")
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

    func saveImage(completion: @escaping (Bool) -> ()) {
        if let imageData = self.image?.jpegData(compressionQuality: 0.5) {
            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image.jpeg"
            let storageRef = storage.reference().child("users").child(self.documentId!).child("image")
            let uploadTask = storageRef.putData(imageData, metadata: uploadMetadata) { (metadata, error) in
                if let error = error { print("🔴 ERROR: Uploading image \(error.localizedDescription)") }
            }
            uploadTask.observe(.success) { (snapshot) in
                print("🟢 DATABASE: Added user image to storage")
                let ref = self.db.collection("users").document(self.documentId!)
                storageRef.downloadURL { (imageUrl, error) in
                    if let error = error {
                        print("🔴 DATABASE ERROR: Downloading user image \(self.documentId!) \(error.localizedDescription)")
                        completion(false)
                    }
                    guard let imageUrl = imageUrl?.absoluteString else {
                        print("🔴 DATABASE ERROR: Downloading user image - no image \(self.documentId!)")
                        completion(false)
                        return
                    }
                    ref.updateData(["image_url": imageUrl]) { (error) in
                        if let error = error {
                            print("🔴 DATABASE ERROR: Adding user image \(self.documentId!) \(error.localizedDescription)")
                            completion(false)
                        }
                        self.imageUrl = imageUrl
                        print("🟢 DATABASE: Updated user \(String(describing: self.documentId!))")
                        completion(true)
                    }
                }
            }
            uploadTask.observe(.failure) { (snapshot) in
                if let error = snapshot.error {
                    print("🔴 DATABASE ERROR: Adding user image to storage \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }

    func detachListeners() {
        if let listener = self.listener {
            listener.remove()
            print("🔷 Listener detached - user")
        }
    }
}
