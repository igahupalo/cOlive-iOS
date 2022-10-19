//
//  Posts.swift
//  cOlive
//
//  Created by Iga Hupalo on 23/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class Posts {
    let db: Firestore = Firestore.firestore()
    let storage: Storage = Storage.storage()
    var postsArray: [Post]
    var listener: ListenerRegistration?

    init() {
        self.postsArray = []
    }

    deinit {
        print("🟦 posts deinit")
    }

    // MARK: Database functions

    func fetch(flat: Flat, completion: @escaping () -> ()) {
        guard let flatId = flat.documentId else {
            print("🔴 ERROR: Fetching events")
            return completion()
        }

        self.listener = db.collection("flats").document(flatId).collection("posts").whereField("is_active", isEqualTo: true).addSnapshotListener { documentSnapshots, error in
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
                    let post = Post(dictionary: document.data())
                    post.documentId = document.documentID

                    if let imageUrl = post.imageUrl {
                        dispatchGroup.enter()
                        let ref = self.storage.reference(forURL: imageUrl)
                        self.getImageData(ref: ref) { (data) in
                            guard data != nil else {
                                return
                            }
                            let image = UIImage(data: data!)
                            dispatchGroup.leave()
                            post.image = image
                            self.postsArray.append(post)
                            print("🟢 Added post with image \(String(describing: post.documentId))")
                        }
                    } else {
                        self.postsArray.append(post)
                        print("🟢 Added post \(String(describing: post.documentId))")
                    }
                }
                if (type == .modified) {
                    if let postIndex = self.postsArray.firstIndex(where: { $0.documentId == documentId }) {
                        self.postsArray[postIndex].setData(dictionary: data)
                        if let imageUrl = self.postsArray[postIndex].imageUrl {
                            dispatchGroup.enter()
                            let ref = self.storage.reference(forURL: imageUrl)
                            self.getImageData(ref: ref) { (data) in
                                guard data != nil else {
                                    return
                                }
                                let image = UIImage(data: data!)
                                dispatchGroup.leave()
                                self.postsArray[postIndex].image = image
                                print("🟢 Updated post \(String(describing: documentId))")
                            }
                        } else {
                            print("🟢 Updated post \(String(describing: documentId))")
                        }
                    }
                }
                if (type == .removed) {
                    if let postIndex = self.postsArray.firstIndex(where: { $0.documentId == documentId }) {
                        self.postsArray.remove(at: postIndex)
                        print("🟢 Deleted post \(String(describing: documentId))")
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.postsArray.sort { ($0.date ?? Date()) > ($1.date ?? Date()) }
                completion()
            }
        }
    }


    func getImageData(ref: StorageReference, completion: @escaping (Data?) -> ()) {
        ref.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("🔴 DATABASE ERROR: Downloading user image \(error!.localizedDescription)")
                completion(nil)
            }
            guard let data = data else {
                print("🔴 DATABASE ERROR: Downloading user image")
                completion(nil)
                return
            }
            completion(data)
        }
    }


    func detachListeners() {
        if let listener = self.listener {
            print("🔷 Listener detached - posts")
            listener.remove()
        }
        self.postsArray.forEach( { $0.detachCommentListener() } )
    }
}
