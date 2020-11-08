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
    var listener: ListenerRegistration?

    init() {
        self.membershipsArray = []
    }

    deinit {
        print("🟦 memberships deinit")
    }

    func fetch(user: User, completion: @escaping () -> ()) {
        guard let userId = user.documentId else {
            print("🔴 ERROR: Fetching memberships")
            return completion()
        }

        self.listener = db.collection("users").document(userId).collection("memberships").addSnapshotListener { documentSnapshots, error in
            guard error == nil else {
                completion()
                return
            }
            guard let snapshots = documentSnapshots else {
                print("🔴 ERROR: Fetching snapshots: \(error!)")
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

            self.membershipsArray.sort { $0.lastUsed > $1.lastUsed }

            completion()
        }
    }

    func fetchFlats(completion: @escaping () -> ()) {
        let dispatchGroup = DispatchGroup()
        membershipsArray.forEach { membership in
            dispatchGroup.enter()
            membership.fetchFlat {
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    func save(user: User, completion: @escaping (Bool) -> ()) {
        
    }

    func detachListeners() {
        if let listener = self.listener {
            print("🔷 Listener detached - memberships")
            listener.remove()
        }
        membershipsArray.forEach( { $0.detachListeners() } )
    }
}
