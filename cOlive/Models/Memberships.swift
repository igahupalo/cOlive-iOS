//
//  Memberships.swift
//  cOlive
//
//  Created by Iga Hupalo on 24/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Memberships {
    let db: Firestore = Firestore.firestore()

    var membershipsArray: [Membership]

    init() {
        self.membershipsArray = []
    }

    func fetchData(user: User, completion: @escaping () -> ()) {
        guard let userId = user.documentId else {
            print("🔴 ERROR: fetching memberships")
            return completion()
        }

        db.collection("users").document(userId).collection("memberships").addSnapshotListener { documentSnapshots, error in
            guard error == nil else {
                completion()
                return
            }

            guard let snapshots = documentSnapshots else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshots.documentChanges.forEach { snapshot in
                let type = snapshot.type
                let document = snapshot.document
                let documentId = document.documentID
                let data = document.data()

                if (type == .added) {
                    let membership = Membership(dictionary: document.data())
                    membership.documentId = document.documentID
                    self.membershipsArray.append(membership)
                    print("🟢 Added membership \(String(describing: membership.documentId))")
                }

                if (type == .modified) {
                    if let membershipIndex = self.membershipsArray.firstIndex(where: { $0.documentId == documentId }) {
                        self.membershipsArray[membershipIndex].setData(dictionary: data)
                        print("🟢 Updated membership \(String(describing: documentId))")
                    }
                }
                if (type == .removed) {
                    if let membershipIndex = self.membershipsArray.firstIndex(where: { $0.documentId == documentId }) {
                        self.membershipsArray.remove(at: membershipIndex)
                        print("🟢 Deleted membership \(String(describing: documentId))")
                    }
                }
            }
            completion()
        }
    }

    func saveData(user: User, completion: @escaping (Bool) -> ()) {
        
    }
}
