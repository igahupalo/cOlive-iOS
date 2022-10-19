//
//  Membership.swift
//  cOlive
//
//  Created by Iga Hupalo on 18/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Membership {
    let db: Firestore = Firestore.firestore()
    var documentId: String?
    var listener: ListenerRegistration?

    var isActive: Bool
    var lastUsed: Date
    var type: MembershipType
    var flatId: String
    var flat: Flat
    
    var dictionary: [String: Any] {
        let timeInterval = lastUsed.timeIntervalSince1970
        return ["flat_id": flatId, "is_active": isActive, "last_used": timeInterval, "type": type.rawValue]
    }

    enum MembershipType: String {
        case normal = "normal"
        case owner = "owner"
    }

    deinit {
        print("🟦 membership deinit")
    }

    init(flatId: String, isActive: Bool, lastUsed: Date, type: MembershipType) {
        self.flatId = flatId
        self.isActive = isActive
        self.lastUsed = lastUsed
        self.type = type
        self.flat = Flat(documentId: flatId != "" ? flatId : nil)
    }

    convenience init(flatId: String, lastUsed: Date, type: MembershipType) {
        let isActive = true
        self.init(flatId: flatId, isActive: isActive, lastUsed: lastUsed, type: type)
    }

    convenience init(documentId: String?) {
        self.init(flatId: "", isActive: true, lastUsed: Date(), type: .normal)
        self.documentId = documentId
    }

    convenience init(flatId: String) {
        self.init(flatId: flatId, isActive: true, lastUsed: Date(), type: .normal)
    }

    convenience init (_ membership: Membership) {
        self.init(flatId: membership.flatId, isActive: membership.isActive, lastUsed: membership.lastUsed, type: membership.type)
        if let documentId = membership.documentId {
            self.documentId = documentId
        }
    }

    convenience init(dictionary: [String: Any]) {
        let flatId = dictionary["flat_id"] as! String? ?? ""
        let isActive = dictionary["is_active"] as! Bool? ?? true
        let timeIntervalDate = dictionary["last_used"] as! TimeInterval? ?? TimeInterval()
        let lastUsed = Date(timeIntervalSince1970: timeIntervalDate)
        let type = dictionary["type"] as? String ?? "" == "normal" ? MembershipType.normal : MembershipType.owner

        self.init(flatId: flatId, isActive: isActive, lastUsed: lastUsed, type: type)
    }

    func setData(dictionary: [String: Any]) {
        self.flatId = dictionary["flat_id"] as! String? ?? ""
        self.isActive = dictionary["is_active"] as! Bool? ?? true
        let timeIntervalDate = dictionary["last_used"] as! TimeInterval? ?? TimeInterval()
        self.lastUsed = Date(timeIntervalSince1970: timeIntervalDate)
        self.type = dictionary["type"] as? String ?? "" == "normal" ? MembershipType.normal : MembershipType.owner
    }

    // MARK: Firebase functions.
    
    func fetchFlat(completion: @escaping () -> ()) {
        if flat.documentId == nil { flat.documentId = self.flatId }
        self.flat.fetch {
            completion()
        }
    }

    func deactivate(user: User, completion: @escaping () -> ()) {
        self.isActive = false
        guard let userId = user.documentId else {
            print("🔴 DATABASE ERROR: Deactivating membership \(String(describing: documentId))")
            return completion()
        }
        let ref = db.collection("users").document(userId).collection("memberships").document(flatId)
        ref.updateData(["is_active": false]) { error in
            if let error = error {
                print("🔴 ERROR: Deactivating membership \(self.flatId) \(error.localizedDescription)")
                completion()
            }
            print("🟢 DATABASE: Deactivated membership \(String(describing: self.flatId))")
            completion()
        }
    }

    func fetch(user: User, completion: @escaping (Bool) -> ()) {
        guard let userId = user.documentId else {
            print("🔴 ERROR: Fetching membership as no user id was given")
            return completion(false)
        }

        guard let documentId = documentId else {
            print("🔴 ERROR: Fetching membership as no membership id was given")
            return completion(false)
        }
        
        db.collection("users").document(userId).collection("memberships").document(documentId).getDocument { documentSnapshot, error in
            guard error == nil else {
                print("🔴 ERROR: Adding membership snapshot listener")
                completion(false)
                return
            }
            if let document = documentSnapshot {
                if let data = document.data() {
                    self.setData(dictionary: data)
                    self.fetchFlat {
                        completion(true)
                    }
                }
            } else {
                completion(false)
                print("🔴 ERROR: Fetching membership.")
            }
        }
    }

    

    func save(user: User, completion: @escaping (Bool) -> ()) {
        guard let userId = user.documentId else {
            print("🔴 DATABASE ERROR: updating membership \(String(describing: documentId))")
            return completion(false)
        }
        let ref = db.collection("users").document(userId).collection("memberships").document(flatId)
        ref.setData(self.dictionary) { error in
            if let error = error {
                print("🔴 ERROR: updating membership \(self.flatId) \(error.localizedDescription)")
                completion(false)
            }
            print("🟢 DATABASE: Updated membership \(String(describing: self.flatId))")
            completion(true)
        }
    }

    func delete(user: User, completion: @escaping () -> ()) {
        if let documentId = documentId {
            if let userId = user.documentId {
                let ref = db.collection("users").document(userId).collection("memberships").document(documentId)
                ref.delete() { error in
                    if let error = error {
                        print("🔴 DATABASE ERROR: deleting flat \(documentId) \(error.localizedDescription)")
                        completion()
                        return
                    }
                    print("🟢 DATABASE: Deleted flat \(String(describing: documentId))")
                    completion()

                }
            }
        }
    }

    func detachListeners() {
        if let listener = self.listener {
            listener.remove()
            print("🔷 Listener detached - membership")
        }
        self.flat.detachListeners()
    }
}

