//
//  Members.swift
//  cOlive
//
//  Created by Iga Hupalo on 24/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Members {
    let db: Firestore = Firestore.firestore()

    var membersArray: [Member]
    var listener: ListenerRegistration?

    init() {
        self.membersArray = []
    }

    func fetch(flat: Flat, currentUser: User, completion: @escaping () -> ()) {
        guard let flatId = flat.documentId else {
            print("🔴 ERROR: Fetching members")
            return completion()
        }

        self.listener = db.collection("flats").document(flatId).collection("members").whereField("is_active", isEqualTo: true).addSnapshotListener { documentSnapshots, error in
            guard error == nil else {
                completion()
                return
            }
            guard let snapshots = documentSnapshots else {
                print("🔴 ERROR: Fetching snapshots: \(error!)")
                return
            }
            let dispatchGroup = DispatchGroup()

            
            snapshots.documentChanges.forEach { snapshot in
                let type = snapshot.type
                let document = snapshot.document
                let documentId = document.documentID
                let data = document.data()

                if (type == .added) {
                    dispatchGroup.enter()
                    let member = Member(dictionary: document.data())
                    member.documentId = document.documentID
                    if member.userId == currentUser.documentId {
                        member.user = currentUser
                        self.membersArray.append(member)
                        print("🟢 Added current member \(String(describing: member.documentId))")
                        dispatchGroup.leave()
                    } else {
                        member.fetchUser {
                            self.membersArray.append(member)
                            print("🟢 Added member \(String(describing: member.documentId))")
                            dispatchGroup.leave()
                        }
                    }
                }
                if (type == .modified) {
                    if let memberIndex = self.membersArray.firstIndex(where: { $0.documentId == documentId }) {
                        self.membersArray[memberIndex].setData(dictionary: data)
                        print("🟢 Updated member \(String(describing: documentId))")
                    }
                }
                if (type == .removed) {
                    if let memberIndex = self.membersArray.firstIndex(where: { $0.documentId == documentId }) {
                        self.membersArray.remove(at: memberIndex)
                        print("🟢 Deleted member \(String(describing: documentId))")
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion()
            }
        }
    }

    func detachListeners() {
        if let listener = self.listener {
            listener.remove()
            print("🔷 Listener detached - members")
        }
//        membersArray.forEach( { $0.detachListeners() } )
    }
}
