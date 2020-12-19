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

class User {
    let db: Firestore = Firestore.firestore()
    let storage: Storage = Storage.storage()
    var documentId: String?

    var profileListener: ListenerRegistration?
    var membershipListener: ListenerRegistration?

    var uid: String
    var displayName: String
    var email: String
    var phoneNumber: String?
    var birthday: Date?
    var membershipId: String?
    var membership: Membership?
    var imageUrl: String?
    var image: UIImage?
    

    var dictionary: [String: Any] {
        let dictionary: [String: Any?] =  ["uid": uid, "display_name": displayName, "email": email, "phone_number": phoneNumber, "birthday": birthday, "image_url": imageUrl, "membership_id": membershipId]
        return dictionary.filter { $0.value != nil } .mapValues { $0! }
    }

    init(uid: String, displayName: String, email: String, phoneNumber: String?, birthday: Date?, imageUrl: String?, membershipId: String?) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
        self.phoneNumber = phoneNumber
        self.birthday = birthday
        self.imageUrl = imageUrl
        self.membershipId = membershipId
    }

    deinit {
        print("🟦 user deinit")
    }

    convenience init(documentId: String) {
        self.init(uid: "", displayName: "", email: "", phoneNumber: nil, birthday: nil, imageUrl: nil, membershipId: nil)
        self.documentId = documentId
    }

    convenience init() {
        self.init(uid: "", displayName: "", email: "", phoneNumber: nil, birthday: nil, imageUrl: nil, membershipId: nil)
    }

    convenience init(uid: String, displayName: String, email: String) {
        let uid = uid
        let displayName = displayName
        let email = email

        self.init(uid: uid, displayName: displayName, email: email, phoneNumber: nil, birthday: nil, imageUrl: nil, membershipId: nil)
    }

    convenience init(dictionary: [String: Any]) {
        let uid = dictionary["uid"] as! String? ?? ""
        let displayName = dictionary["display_name"] as! String? ?? ""
        let email = dictionary["email"] as! String? ?? ""
        let phoneNumber = dictionary["phone_number"] as! String?
        let timeIntervalDate = dictionary["birthday"] as! TimeInterval? ?? TimeInterval()
        let birthday = Date(timeIntervalSince1970: timeIntervalDate)
        let imageUrl = dictionary["image_url"] as! String?
        let membershipId = dictionary["membership_id"] as! String?

        self.init(uid: uid, displayName: displayName, email: email, phoneNumber: phoneNumber, birthday: birthday, imageUrl: imageUrl, membershipId: membershipId)
    }

    func setData(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as! String? ?? ""
        self.displayName = dictionary["display_name"] as! String? ?? ""
        self.email = dictionary["email"] as! String? ?? ""
        self.phoneNumber = dictionary["phone_number"] as! String?
        let birthdayTimeInterval = dictionary["birthday"] as! TimeInterval?
        if let birthdayTimeInterval = birthdayTimeInterval { self.birthday = Date(timeIntervalSince1970: birthdayTimeInterval) }
        self.imageUrl = dictionary["image_url"] as! String?
        self.membershipId = dictionary["membership_id"] as! String?
    }

    // MARK: Firebase functions.

    func setMembership(membershipId: String, completion: @escaping () -> ()) {
        if let membership = self.membership {
            membership.detachListeners()
        }
        self.membership = Membership(documentId: membershipId)
        self.fetchMembership {
            if let membershipId = self.membership?.documentId {
                self.changeMembershipId(membershipId: membershipId) {
                    completion()
                }
            }
        }
    }

    func deactivateMembership(flat: Flat, completion: @escaping () -> ()) {
        guard let flatId = flat.documentId else {
            completion()
            return
        }
        if membershipId == flatId {
            if let membership = self.membership {
                membership.deactivate(user: self) {
                    completion()
                    return
                }
            } else {
                let membership = Membership(flatId: flatId)
                membership.deactivate(user: self) {
                    completion()
                }
            }
        }
    }

    func checkIn(code: String, completion: @escaping (CheckInError?) -> ()) {
        guard let userId = self.documentId else {
            completion(nil)
            return
        }
        let invitationCode = InvitationCode(code: code)

        invitationCode.fetchValid { (success) in
            guard success else {
                completion(CheckInError.invalidCode)
                print("🔴 niepoprawny kod")
                return
            }

            guard let flatId = invitationCode.flatId else {
                completion(CheckInError.invalidCode)
                return
            }
            let flat = Flat(documentId: flatId)
            flat.isActive() { (isActive) in
                guard isActive else {
                    completion(CheckInError.invalidCode)
                    return
                }

                print("🟢 poprawny kod")

                let member = Member(userId: userId)
                let membership = Membership(flatId: flatId)
                membership.fetch(user: self) { (membershipFetchSuccess) in
                    if membershipFetchSuccess {
                        // Already a member of this flat group.
                        if membership.isActive {
                            membership.detachListeners()
                            completion(CheckInError.alreadyMember)
                            return
                        }
                        // Former member of this flat group.
                        membership.isActive = true
                        membership.lastUsed = Date()
                        membership.save(user: self) { (membershipSaveSuccess) in
                            guard membershipSaveSuccess else {
                                membership.detachListeners()
                                completion(nil)
                                return
                            }
                            member.fetch(flat: flat) { (memberFetchSuccess) in
                                guard memberFetchSuccess else {
                                    member.detachListeners()
                                    completion(nil)
                                    return
                                }
                                member.isActive = true
                                member.save(flat: flat) { (memberFetchSuccess) in
                                    guard memberFetchSuccess else {
                                        member.detachListeners()
                                        completion(nil)
                                        return
                                    }
                                    self.membership = membership
                                    self.changeMembershipId(membershipId: flatId) {
                                        completion(nil)
                                    }
                                }
                            }
                        }
                    } else {
                        // New member of this flat group.
                        membership.detachListeners()
                        membership.save(user: self) { (membershipSaveSuccess) in
                            guard membershipSaveSuccess else {
                                membership.detachListeners()
                                completion(nil)
                                return
                            }
                            member.save(flat: flat) { (memberFetchSuccess) in
                                guard memberFetchSuccess else {
                                    member.detachListeners()
                                    completion(nil)
                                    return
                                }
                                self.membership = membership
                                self.changeMembershipId(membershipId: flatId) {
                                    completion(nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func fetchMembership(completion: @escaping () -> ()) {
        if self.membership == nil { self.membership = Membership(documentId: self.membershipId) }
        self.membership?.fetch(user: self) { (_) in
            completion()
        }
    }

    func fetchCurrent(completion: @escaping () -> ()) {
        if let currentUser = Auth.auth().currentUser {
            db.collection("users").whereField("uid", isEqualTo: currentUser.uid).limit(to: 1).getDocuments { documentSnapshots, error in
                guard error == nil else {
                    print("🔴 DATABASE ERROR: Fetching current user \(String(describing: error?.localizedDescription))")
                    completion()
                    return
                }

                guard documentSnapshots != nil else {
                    print("🔴 DATABASE ERROR: Fetching current user.")
                    completion()
                    return
                }

                guard documentSnapshots!.documents.count > 0 else {
                    print("🔴 DATABASE ERROR: Fetching current user as document does not exist.")
                    completion()
                    return
                }

                guard documentSnapshots!.documents.count == 1 else {
                    print("🔴 DATABASE ERROR: Fetching current user as more than one current user.")
                    completion()
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
                        if self.membershipId != nil  {
                            self.fetchMembership {
                                completion()
                            }
                        } else {
                            completion()
                        }
                    }
                } else {
                    if self.membershipId != nil  {
                        self.fetchMembership {
                            completion()
                        }
                    } else {
                        completion()
                    }
                }
            }
        }
    }

    func changeMembershipId(membershipId: String?, completion: @escaping () -> ()) {
        if let documentId = self.documentId {
            let ref = db.collection("users").document(documentId)
            ref.updateData(["membership_id": membershipId == nil ? FieldValue.delete() : membershipId!]) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: updating user membership id \(documentId) \(error.localizedDescription)")
                    completion()
                }
                print("🟢 DATABASE: Updated user membership id \(String(describing: documentId))")
                completion()
            }
        } else { completion() }
    }

    func addMembershipListener(completion: @escaping () -> ()) {
        guard let userId = self.documentId else {
            completion()
            return
        }
        self.membershipListener = db.collection("users").document(userId).addSnapshotListener { documentSnapshot, error in

            guard error == nil else {
                print("🔴 DATABASE ERROR: Fetching current user \(String(describing: error?.localizedDescription))")
                completion()
                return
            }

            guard let document = documentSnapshot else {
                print("🔴 DATABASE ERROR: Fetching current user.")
                completion()
                return
            }

            let membershipId = document.data()?["membership_id"] as? String ?? nil

            if self.membershipId != membershipId {
                self.membershipId = membershipId
                if membershipId != nil {
                    self.membership?.documentId = membershipId
                    self.membership?.detachListeners()
                    self.fetchMembership {
                         completion()
                    }
                } else {
                    completion()
                }
            }
        }
    }

    func fetch(completion: @escaping () -> ()) {
        guard documentId != nil  else {
            print("🔴 ERROR: Fetching user as no user id was given")
            return completion()
        }
        db.collection("users").document(documentId!).getDocument { documentSnapshot, error in
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
                    } else {
                        completion()
                    }
                }
            }
        }
    }

    func addProfileListener(completion: @escaping () -> ()) {
        guard documentId != nil  else {
            print("🔴 ERROR: Fetching user as no user id was given")
            return completion()
        }
        self.profileListener = db.collection("users").document(documentId!).addSnapshotListener { documentSnapshot, error in
            guard error == nil else {
                print("🔴 ERROR: Adding user snapshot listener")
                completion()
                return
            }
            if let document = documentSnapshot {
                if let data = document.data() {

                    self.displayName = data["display_name"] as! String? ?? ""
                    self.email = data["email"] as! String? ?? ""
                    self.phoneNumber = data["phone_number"] as! String?
                    let birthdayTimeInterval = data["birthday"] as! TimeInterval?
                    if let birthdayTimeInterval = birthdayTimeInterval { self.birthday = Date(timeIntervalSince1970: birthdayTimeInterval) }
                    self.imageUrl = data["image_url"] as! String?

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
                print("🟢 DATABASE: Created user \(String(describing: self.documentId))")
                completion(true)
            }
        }
    }

    func saveDisplayName(completion: @escaping () -> ()) {
        if let documentId = self.documentId {
            let ref = db.collection("users").document(documentId)
            ref.updateData(["display_name": self.displayName]) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: updating user display name \(documentId) \(error.localizedDescription)")
                    completion()
                }
                print("🟢 DATABASE: Updated user display name \(String(describing: documentId))")
                completion()
            }
        } else { completion() }
    }

    func savePhoneNumber(completion: @escaping () -> ()) {
        if let documentId = self.documentId {
            let ref = db.collection("users").document(documentId)
            ref.updateData(["phone_number": self.phoneNumber ?? FieldValue.delete()]) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: updating user phone number \(documentId) \(error.localizedDescription)")
                    completion()
                }
                print("🟢 DATABASE: Updated user phone number \(String(describing: documentId))")
                completion()
            }
        } else { completion() }
    }

    func saveBirthday(completion: @escaping () -> ()) {
        if let documentId = self.documentId {
            let ref = db.collection("users").document(documentId)
            ref.updateData(["birthday": self.birthday?.timeIntervalSince1970 ?? FieldValue.delete()]) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: updating user birthday \(documentId) \(error.localizedDescription)")
                    completion()
                }
                print("🟢 DATABASE: Updated user birthday \(String(describing: documentId))")
                completion()
            }
        } else { completion() }
    }

    func saveEmail(completion: @escaping () -> ()) {
        if let documentId = self.documentId {
            let ref = db.collection("users").document(documentId)
            ref.updateData(["email": self.displayName]) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: updating user email \(documentId) \(error.localizedDescription)")
                    completion()
                }
                print("🟢 DATABASE: Updated user email\(String(describing: documentId))")
                completion()
            }
        } else { completion() }
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

    func detachMembershipListener() {
        if let listener = self.membershipListener {
            listener.remove()
            print("🔷 Listener detached - user")
        }
        self.membership?.detachListeners()
    }

    func detachProfileListener() {
        if let listener = self.profileListener {
            listener.remove()
            print("🔷 Profile listener detached - user")
        }
    }
}
