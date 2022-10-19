//
//  Comments.swift
//  cOlive
//
//  Created by Iga Hupalo on 26/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore


class Comments {
    let db: Firestore = Firestore.firestore()
    var commentsArray: [Comment]
    var listener: ListenerRegistration?
    var commentNuberListener: ListenerRegistration?

    init() {
        self.commentsArray = []
    }

    deinit {
        print("🟦 comments deinit")
    }

    // MARK: Database functions

    func fetch(flat: Flat, postId: String, completion: @escaping () -> ()) {
        guard let flatId = flat.documentId else {
            print("🔴 ERROR: Fetching comments")
            return completion()
        }

        self.listener = db.collection("flats").document(flatId).collection("posts").document(postId).collection("comments").whereField("is_active", isEqualTo: true).addSnapshotListener { documentSnapshots, error in
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
                    let comment = Comment(dictionary: document.data())
                    comment.documentId = document.documentID
                    self.commentsArray.append(comment)
                    print("🟢 Added comment \(String(describing: comment.documentId))")
                }
                if (type == .modified) {
                    if let commentIndex = self.commentsArray.firstIndex(where: { $0.documentId == documentId }) {
                        self.commentsArray[commentIndex].setData(dictionary: data)
                        print("🟢 Updated comment \(String(describing: documentId))")
                    }
                }
                if (type == .removed) {
                    if let commentIndex = self.commentsArray.firstIndex(where: { $0.documentId == documentId }) {
                        self.commentsArray.remove(at: commentIndex)
                        print("🟢 Deleted comment \(String(describing: documentId))")
                    }
                }
            }

            self.commentsArray.sort { $0.date < $1.date }
            completion()
        }
    }


    func detachListeners() {
        if let listener = self.listener {
            print("🔷 Listener detached - comments")
            listener.remove()
        }
    }
}
