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

    deinit {
        print("🟦 members deinit")
    }

    func addListener(flat: Flat, currentUser: User, completion: @escaping () -> ()) {
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
                    if documentId == currentUser.documentId {
                        let member = CurrentMember(dictionary: document.data())
                        member.documentId = document.documentID
                        member.user = currentUser
                        self.membersArray.append(member)
                        print("🟢 Added current member \(String(describing: member.documentId))")
                    } else {
                        dispatchGroup.enter()
                        let member = Member(dictionary: document.data())
                        member.documentId = document.documentID
                        self.membersArray.append(member)
                        print("🟢 Added member \(String(describing: member.documentId))")
                        member.fetchUser {
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
                let currentMemberIndex = self.membersArray.firstIndex(where: { $0.userId == currentUser.documentId } )
                if let currentMemberIndex = currentMemberIndex {
                    let currentMember = self.membersArray.remove(at: currentMemberIndex)
                    self.membersArray.insert(currentMember, at: self.membersArray.count)
                }
                completion()
            }
        }
    }

    func fetch(flat: Flat, currentUser: User, completion: @escaping () -> ()) {
        guard let flatId = flat.documentId else {
            print("🔴 ERROR: Fetching members")
            return completion()
        }

        db.collection("flats").document(flatId).collection("members").whereField("is_active", isEqualTo: true).getDocuments { documentSnapshots, error in
            guard error == nil else {
                completion()
                return
            }
            guard let snapshots = documentSnapshots else {
                print("🔴 ERROR: Fetching snapshots: \(error!)")
                return
            }

            let dispatchGroup = DispatchGroup()
            snapshots.documents.forEach { document in
                let documentId = document.documentID
                let data = document.data()
                if documentId == currentUser.documentId {
                    let member = CurrentMember(dictionary: data)
                    member.documentId = document.documentID
                    member.user = currentUser
                    self.membersArray.append(member)
                    print("🟢 Added current member \(String(describing: member.documentId))")
                } else {
                    dispatchGroup.enter()
                    let member = Member(dictionary: document.data())
                    member.documentId = document.documentID
                    self.membersArray.append(member)
                    print("🟢 Added member \(String(describing: member.documentId))")
                    member.fetchUser {
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                let currentMemberIndex = self.membersArray.firstIndex(where: { $0.userId == currentUser.documentId } )
                if let currentMemberIndex = currentMemberIndex {
                    let currentMember = self.membersArray.remove(at: currentMemberIndex)
                    self.membersArray.insert(currentMember, at: self.membersArray.count)
                }
                completion()
            }
        }
    }

    func detachListeners() {
        if let listener = self.listener {
            listener.remove()
            print("🔷 Listener detached - members")
        }
        membersArray.forEach( { $0.detachListeners() } )
    }
}
