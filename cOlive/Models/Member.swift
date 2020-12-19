//
//  Member.swift
//  cOlive
//
//  Created by Iga Hupalo on 18/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Member {
    let db: Firestore = Firestore.firestore()
    var documentId: String?
    var userId: String
    var isActive: Bool
    var user: User?

    var listener: ListenerRegistration?

    var dictionary: [String: Any] {
        return ["user_id": self.userId, "is_active": self.isActive]
    }

    deinit {
        print("🟦 member deinit")
    }

    init(userId: String, isActive: Bool) {
        self.userId = userId
        self.isActive = isActive
    }

    convenience init(userId: String) {
        let userId = userId
        let isActive = true
        self.init(userId: userId, isActive: isActive)
    }

    convenience init(dictionary: [String: Any]) {
        let userId = dictionary["user_id"] as! String? ?? ""
        let isActive = dictionary["is_active"] as! Bool? ?? true

        self.init(userId: userId, isActive: isActive)
    }

    func setData(dictionary: [String: Any]) {
        self.userId = dictionary["user_id"] as! String? ?? ""
        self.isActive = dictionary["is_active"] as! Bool? ?? true
    }

    func fetchUser(completion: @escaping () -> ()) {
        if self.user == nil { self.user = User() }
        if self.user?.documentId == nil { user?.documentId = self.userId }
        self.user?.fetch {
            completion()
        }
    }

    func removeFrom(flat: Flat, completion: @escaping () -> ()) {
        guard let flatId = flat.documentId else {
            completion()
            return
        }
        self.user?.deactivateMembership(flat: flat) {
           if self.user?.membershipId == flatId {
                self.user?.changeMembershipId(membershipId: nil) {
                    self.user?.membership?.detachListeners()
                    self.user?.membership = nil
                    self.user = nil
                    self.detachListeners()
                    self.deactivate(flat: flat) {
                        completion()
                    }
                    return
                }
           } else {
               self.user?.membership?.detachListeners()
               self.user = nil
               self.detachListeners()
               self.deactivate(flat: flat) {
                   completion()
               }
           }
        }
    }

    func deactivate(flat: Flat, completion: @escaping () -> ()) {
        self.isActive = false
        guard let flatId = flat.documentId else {
            print("🔴 DATABASE ERROR: Deactivating member \(String(describing: documentId))")
            return completion()
        }
        let ref = db.collection("flats").document(flatId).collection("members").document(userId)
        ref.updateData(["is_active": false]) { error in
            if let error = error {
                print("🔴 DATABASE ERROR: Deactivating member \(self.userId) \(error.localizedDescription)")
                completion()
            }
            print("🟢 DATABASE: Deactivated member \(String(describing: self.userId))")
            completion()
        }
    }


    func fetch(flat: Flat, completion: @escaping (Bool) -> ()) {
        guard let flatId = flat.documentId else {
            print("🔴 ERROR: Fetching member as no flat id was given")
            return completion(false)
        }
        db.collection("flat").document(flatId).collection("members").document(userId).getDocument { documentSnapshot, error in
            guard error == nil else {
                print("🔴 ERROR: Adding membership snapshot listener")
                completion(false)
                return
            }
            if let document = documentSnapshot {
                if let data = document.data() {
                    self.setData(dictionary: data)
                    completion(true)
                }
            }
            completion(false)
        }
    }

    func save(flat: Flat, completion: @escaping (Bool) -> ()) {
        guard let flatId = flat.documentId else {
            print("🔴 DATABASE ERROR: updating member \(String(describing: documentId))")
            return completion(false)
        }
        let ref = db.collection("flats").document(flatId).collection("members").document(userId)
        ref.setData(self.dictionary) { error in
            if let error = error {
                print("🔴 ERROR: updating member \(self.userId) \(error.localizedDescription)")
                completion(false)
            }
            print("🟢 DATABASE: Updated member \(String(describing: self.userId))")
            completion(true)
        }
    }

    func delete(flat: Flat) {
        if let documentId = documentId {
            if let flatId = flat.documentId {
                let ref = db.collection("flats").document(flatId).collection("members").document(documentId)
                ref.delete() { error in
                    if let error = error {
                        print("🔴 DATABASE ERROR: deleting member \(documentId) \(error.localizedDescription)")
                        return
                    }
                    print("🟢 DATABASE: Deleted member \(String(describing: documentId))")
                }
            }
        }
    }

    func detachListeners() {
        if let listener = self.listener {
            listener.remove()
            print("🔷 Listener detached - member")
        }
    }
}

class CurrentMember: Member {
    weak var currentUser: User?
    override var user: User? {
        get {
            return self.currentUser
        }
        set {
            currentUser = newValue
        }
    }
}
