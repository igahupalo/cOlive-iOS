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

    var flatId: String
    var isActive: Bool
    var lastUsed: Date
    var type: MembershipType

    var flat: Flat? = nil
    
    var dictionary: [String: Any] {
        let timeInterval = lastUsed.timeIntervalSince1970
        return ["flat_id": flatId, "is_active": isActive, "last_used": timeInterval, "type": type.rawValue]
    }

    enum MembershipType: String {
        case normal = "normal"
        case owner = "owner"
    }

    init(flatId: String, isActive: Bool, lastUsed: Date, type: MembershipType) {
        self.flatId = flatId
        self.isActive = isActive
        self.lastUsed = lastUsed
        self.type = type
    }

    convenience init(flatId: String, lastUsed: Date, type: MembershipType) {
        let isActive = true
        self.init(flatId: flatId, isActive: isActive, lastUsed: lastUsed, type: type)
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

    //MARK: Firebase functions.

    func saveData(user: User, completion: @escaping (Bool) -> ()) {
        guard let userId = user.documentId else {
            print("🔴 ERROR: updating membership \(String(describing: documentId))")
            return completion(false)
        }
        if let documentId = documentId {
            let ref = db.collection("users").document(userId).collection("memberships").document(documentId)
            ref.setData(self.dictionary) { error in
                if let error = error {
                    print("🔴 ERROR: updating membership \(documentId) \(error.localizedDescription)")
                    completion(false)
                }
                print("🟢 Updated membership \(String(describing: documentId))")
                completion(true)
            }
        } else {
            let ref = db.collection("users").document(userId).collection("memberships").document()
            ref.setData(self.dictionary) { error in
                if let error = error {
                    print("🔴 ERROR: creating membership \(error.localizedDescription)")
                    completion(false)
                }
                self.documentId = ref.documentID
                print("🟢 Created membership \(String(describing: self.documentId))")
                completion(true)
            }
        }
    }
}

