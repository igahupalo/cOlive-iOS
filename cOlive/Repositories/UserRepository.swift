//
//  UserRepository.swift
//  cOlive
//
//  Created by Iga Hupalo on 20/10/2022.
//  Copyright © 2022 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class UserRepository {
    let db: Firestore = Firestore.firestore()
    let storage: Storage = Storage.storage()

    var profileListener: ListenerRegistration?
    var membershipListener: ListenerRegistration?

    func setMembership(user: User, membershipId: String, completion: @escaping () -> ()) {
        if let membership = user.membership {
            membership.detachListeners()
        }
        user.membership = Membership(documentId: membershipId)
        fetchMembership(user: user) { [weak self] in
            if let membershipId = user.membership?.documentId {
                self?.changeMembershipId(user: user, membershipId: membershipId) {
                    completion()
                }
            }
        }
    }

    func deactivateMembership(user: User, flat: Flat, completion: @escaping () -> ()) {
        guard let flatId = flat.documentId else {
            completion()
            return
        }
        if user.membershipId == flatId {
            if let membership = user.membership {
                membership.deactivate(user: user) {
                    completion()
                    return
                }
            } else {
                let membership = Membership(flatId: flatId)
                membership.deactivate(user: user) {
                    completion()
                }
            }
        }
    }

    func checkIn(user: User, code: String, completion: @escaping (CheckInError?) -> ()) {
        guard let userId = user.documentId else {
            completion(nil)
            return
        }
        let invitationCode = InvitationCode(code: code)

        invitationCode.fetchValid { (success) in
            guard success else {
                completion(CheckInError.invalidCode)
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

                let member = Member(userId: userId)
                let membership = Membership(flatId: flatId)

                membership.fetch(user: user) { (membershipFetchSuccess) in
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
                        membership.save(user: user) { (membershipSaveSuccess) in
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
                                    user.membership = membership
                                    self.changeMembershipId(user: user, membershipId: flatId) {
                                        completion(nil)
                                    }
                                }
                            }
                        }
                    } else {
                        // New member of this flat group.
                        membership.detachListeners()
                        membership.save(user: user) { (membershipSaveSuccess) in
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
                                user.membership = membership
                                self.changeMembershipId(user: <#User#>, membershipId: flatId) {
                                    completion(nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func fetchMembership(user: User, completion: @escaping () -> ()) {
        if user.membership == nil {
            user.membership = Membership(documentId: user.membershipId)
        }
        user.membership?.fetch(user: user) { (_) in
            completion()
        }
    }

    func fetchCurrent(user: User, completion: @escaping () -> ()) {
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
                user.setData(dictionary: document.data())
                user.documentId = document.documentID

                if let imageUrl = user.imageUrl {
                    let ref = self.storage.reference(forURL: imageUrl)
                    self.getImageData(ref: ref) { (data) in
                        guard data != nil else {
                            completion()
                            return
                        }
                        let image = UIImage(data: data!)
                        user.image = image
                        if user.membershipId != nil  {
                            self.fetchMembership(user: user) {
                                completion()
                            }
                        } else {
                            completion()
                        }
                    }
                } else {
                    if user.membershipId != nil  {
                        self.fetchMembership(user: user) {
                            completion()
                        }
                    } else {
                        completion()
                    }
                }
            }
        }
    }

    func changeMembershipId(user: User, membershipId: String?, completion: @escaping () -> ()) {
        if let documentId = user.documentId {
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

    func addMembershipListener(user: User, completion: @escaping () -> ()) {
        guard let userId = user.documentId else {
            completion()
            return
        }
        membershipListener = db.collection("users").document(userId).addSnapshotListener { documentSnapshot, error in

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

            if user.membershipId != membershipId {
                user.membershipId = membershipId
                if membershipId != nil {
                    user.membership?.documentId = membershipId
                    user.membership?.detachListeners()
                    self.fetchMembership(user: user) {
                         completion()
                    }
                } else {
                    completion()
                }
            }
        }
    }

    func fetch(user: User, completion: @escaping () -> ()) {
        guard let userId = user.documentId else {
            print("🔴 ERROR: Fetching user as no user id was given")
            return completion()
        }
        db.collection("users").document(userId).getDocument { documentSnapshot, error in
            guard error == nil else {
                print("🔴 ERROR: Adding user snapshot listener")
                completion()
                return
            }
            if let document = documentSnapshot {
                if let data = document.data() {
                    user.setData(dictionary: data)
                    if let imageUrl = user.imageUrl {
                        let ref = self.storage.reference(forURL: imageUrl)
                        self.getImageData(ref: ref) { (data) in
                            guard data != nil else {
                                completion()
                                return
                            }
                            let image = UIImage(data: data!)
                            user.image = image
                            completion()
                        }
                    } else {
                        completion()
                    }
                }
            }
        }
    }

    func addProfileListener(user: User, completion: @escaping () -> ()) {
        guard let userId = user.documentId else {
            print("🔴 ERROR: Fetching user as no user id was given")
            return completion()
        }
        profileListener = db.collection("users").document(userId).addSnapshotListener { documentSnapshot, error in
            guard error == nil else {
                print("🔴 ERROR: Adding user snapshot listener")
                completion()
                return
            }
            if let document = documentSnapshot {
                if let data = document.data() {

                    user.displayName = data["display_name"] as! String? ?? ""
                    user.email = data["email"] as! String? ?? ""
                    user.phoneNumber = data["phone_number"] as! String?
                    let birthdayTimeInterval = data["birthday"] as! TimeInterval?
                    if let birthdayTimeInterval = birthdayTimeInterval { user.birthday = Date(timeIntervalSince1970: birthdayTimeInterval) }
                    user.imageUrl = data["image_url"] as! String?

                    if let imageUrl = user.imageUrl {
                        let ref = self.storage.reference(forURL: imageUrl)
                        self.getImageData(ref: ref) { (data) in
                            guard data != nil else {
                                completion()
                                return
                            }
                            let image = UIImage(data: data!)
                            user.image = image
                            completion()
                        }
                    }
                }
            }
        }
    }

    func save(user: User, completion: @escaping (Bool) -> ()) {
        if let documentId = user.documentId {
            let ref = db.collection("users").document(documentId)
            ref.setData(user.dictionary) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: updating user \(documentId) \(error.localizedDescription)")
                    completion(false)
                }
                print("🟢 DATABASE: Updated user \(String(describing: documentId))")
                completion(true)
            }
        } else {
            let ref = db.collection("users").document()
            ref.setData(user.dictionary) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: Creating user \(error.localizedDescription)")
                    completion(false)
                }
                user.documentId = ref.documentID
                print("🟢 DATABASE: Created user \(String(describing: user.documentId))")
                completion(true)
            }
        }
    }

    func saveDisplayName(user: User, completion: @escaping () -> ()) {
        if let documentId = user.documentId {
            let ref = db.collection("users").document(documentId)
            ref.updateData(["display_name": user.displayName]) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: updating user display name \(documentId) \(error.localizedDescription)")
                    completion()
                }
                print("🟢 DATABASE: Updated user display name \(String(describing: documentId))")
                completion()
            }
        } else { completion() }
    }

    func savePhoneNumber(user: User, completion: @escaping () -> ()) {
        if let documentId = user.documentId {
            let ref = db.collection("users").document(documentId)
            ref.updateData(["phone_number": user.phoneNumber ?? FieldValue.delete()]) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: updating user phone number \(documentId) \(error.localizedDescription)")
                    completion()
                }
                print("🟢 DATABASE: Updated user phone number \(String(describing: documentId))")
                completion()
            }
        } else { completion() }
    }

    func saveBirthday(user: User, completion: @escaping () -> ()) {
        if let documentId = user.documentId {
            let ref = db.collection("users").document(documentId)
            ref.updateData(["birthday": user.birthday?.timeIntervalSince1970 ?? FieldValue.delete()]) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: updating user birthday \(documentId) \(error.localizedDescription)")
                    completion()
                }
                print("🟢 DATABASE: Updated user birthday \(String(describing: documentId))")
                completion()
            }
        } else { completion() }
    }

    func saveEmail(user: User, completion: @escaping () -> ()) {
        if let documentId = user.documentId {
            let ref = db.collection("users").document(documentId)
            ref.updateData(["email": user.displayName]) { error in
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

    func saveImage(user: User, completion: @escaping (Bool) -> ()) {
        if let imageData = user.image?.jpegData(compressionQuality: 0.5) {
            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image.jpeg"
            let storageRef = storage.reference().child("users").child(user.documentId!).child("image")
            let uploadTask = storageRef.putData(imageData, metadata: uploadMetadata) { (metadata, error) in
                if let error = error { print("🔴 ERROR: Uploading image \(error.localizedDescription)") }
            }
            uploadTask.observe(.success) { (snapshot) in
                print("🟢 DATABASE: Added user image to storage")
                let ref = self.db.collection("users").document(user.documentId!)
                storageRef.downloadURL { (imageUrl, error) in
                    if let error = error {
                        print("🔴 DATABASE ERROR: Downloading user image \(user.documentId!) \(error.localizedDescription)")
                        completion(false)
                    }
                    guard let imageUrl = imageUrl?.absoluteString else {
                        print("🔴 DATABASE ERROR: Downloading user image - no image \(user.documentId!)")
                        completion(false)
                        return
                    }
                    ref.updateData(["image_url": imageUrl]) { (error) in
                        if let error = error {
                            print("🔴 DATABASE ERROR: Adding user image \(user.documentId!) \(error.localizedDescription)")
                            completion(false)
                        }
                        user.imageUrl = imageUrl
                        print("🟢 DATABASE: Updated user \(String(describing: user.documentId!))")
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

    func detachMembershipListener(user: User) {
        if let listener = self.membershipListener {
            listener.remove()
            print("🔷 Listener detached - user")
        }
        user.membership?.detachListeners()
    }

    func detachProfileListener() {
        if let listener = self.profileListener {
            listener.remove()
            print("🔷 Profile listener detached - user")
        }
    }
}
