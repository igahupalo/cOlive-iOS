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
    var address: String?
    var isActive: Bool
    var members: Members?

    var dictionary: [String: Any] {
        let dictionary = ["name": name, "owner_id": ownerId, "address": address, "is_active": isActive] as [String: Any?]
        return dictionary.filter { $0.value != nil } .mapValues { $0! }
    }

    deinit {
        print("🟦 flat deinit")
    }

    init(name: String, ownerId: String, address: String?, isActive: Bool) {
        self.name = name
        self.ownerId = ownerId
        self.address = address
        self.isActive = isActive
    }

    convenience init(documentId: String?) {
        self.init(name: "", ownerId: "", address: nil, isActive: true)
        self.documentId = documentId
    }

    func fetchMembers(currentUser: User, completion: @escaping () -> ()) {
        if self.members == nil { self.members = Members() }
        self.members!.addListener(flat: self, currentUser: currentUser) {
            completion()
        }
    }

    func isActive(completion: @escaping (Bool) -> ()) {
        guard documentId != nil else {
            print("🔴 ERROR: Fetching flat as no flat id was given")
            return completion(false)
        }
        db.collection("flats").document(documentId!).getDocument { documentSnapshot, error in
            guard error == nil else {
                print("🔴 ERROR: Adding flat snapshot listener")
                completion(false)
                return
            }
            if let document = documentSnapshot {
                if let data = document.data() {
                    completion(data["is_active"] as? Bool ?? false)
                }
            }
        }
    }

    func fetch(completion: @escaping () -> ()) {
        guard documentId != nil else {
            print("🔴 ERROR: Fetching flat as no flat id was given")
            return completion()
        }
        db.collection("flats").document(documentId!).getDocument { documentSnapshot, error in
            guard error == nil else {
                print("🔴 ERROR: Adding flat snapshot listener")
                completion()
                return
            }
            if let document = documentSnapshot {
                if let data = document.data() {
                    self.name = data["name"] as? String ?? ""
                    self.ownerId = data["owner_id"] as? String ?? ""
                    self.address = data["address"] as? String ?? nil
                    self.isActive = data["is_active"] as? Bool ?? true

                    completion()
                }
            }
        }
    }

    func saveName(completion: @escaping () -> ()) {
        if let documentId = self.documentId {
            let ref = db.collection("flats").document(documentId)
            ref.updateData(["name": self.name]) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: updating flat name \(documentId) \(error.localizedDescription)")
                    completion()
                }
                print("🟢 DATABASE: Updated flat name \(String(describing: documentId))")
                completion()
            }
        } else { completion() }
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
            completion(true)
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
                    self.delete() {}
                    return
                }

                // Create member
                guard let userId = user.documentId else {
                    print("🔴 ERROR: No membership created.")
                    completion(false)
                    membership.delete(user: user) {
                        self.delete() {}
                    }
                    return
                }

                let member = Member(userId: userId, isActive: true)

                member.save(flat: self) { (memberSuccess) in
                    guard memberSuccess else {
                        print("🔴 ERROR: No member created.")
                        completion(false)
                        membership.delete(user: user) {
                            self.delete() {}
                        }
                        return
                    }

                    user.membership = membership
                    user.changeMembershipId(membershipId: membership.flatId) {
                        completion(true)
                    }
                }
            }
        }
    }

    func delete(completion: @escaping () -> ()) {
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
        self.members?.detachListeners()
    }
}
