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
    var user: User

    var dictionary: [String: Any] {
        return ["user_id": self.userId, "is_active": self.isActive]
    }

    init(userId: String, isActive: Bool) {
        self.userId = userId
        self.isActive = isActive
        self.user = User(documentId: userId)
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
        if user.documentId == "" { user.documentId = self.userId }
        self.user.fetch {
            completion()
        }
    }

    func save(flat: Flat, completion: @escaping (Bool) -> ()) {
        guard let flatId = flat.documentId else {
            print("🔴 DATABASE ERROR: updating member \(String(describing: documentId))")
            return completion(false)
        }
        if let documentId = documentId {
            let ref = db.collection("flats").document(flatId).collection("members").document(documentId)
            ref.setData(self.dictionary) { error in
                if let error = error {
                    print("🔴 ERROR: updating member \(documentId) \(error.localizedDescription)")
                    completion(false)
                }
                print("🟢 DATABASE: Updated member \(String(describing: documentId))")
                completion(true)
            }
        } else {
            let ref = db.collection("flats").document(flatId).collection("members").document()
            ref.setData(self.dictionary) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: creating member \(error.localizedDescription)")
                    completion(false)
                }
                self.documentId = ref.documentID
                print("🟢 DATABASE: Created member \(String(describing: self.documentId))")
                completion(true)
            }
        }
    }

//    func detachListeners() {
//        if let listener = self.listener {
//            listener.remove()
//            print("🔷 Listener detached - member")
//        }
//    }
}
