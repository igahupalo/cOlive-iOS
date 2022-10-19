//
//  Comment.swift
//  cOlive
//
//  Created by Iga Hupalo on 25/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore


class Comment {
    let db: Firestore = Firestore.firestore()
    var documentId: String?

    var authorId: String
    var date: Date
    var content: String
    var isActive: Bool
//    var author: Member?


    var dictionary: [String: Any] {
        let timeInterval = self.date.timeIntervalSince1970
        return ["author_id": authorId, "date": timeInterval, "content": content, "is_active": isActive]
    }

    init(authorId: String, date: Date, content: String, isActive: Bool) {
        self.authorId = authorId
        self.date = date
        self.content = content
        self.isActive = isActive
    }

    convenience init(authorId: String, date: Date, content: String) {
        self.init(authorId: authorId, date: date, content: content, isActive: true)
    }

    convenience init(dictionary: [String: Any]) {
        let content = dictionary["content"] as! String? ?? ""
        let dateTimeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: dateTimeIntervalDate)
        let authorId = dictionary["author_id"] as! String? ?? ""
        let isActive = dictionary["is_active"] as! Bool? ?? true
        self.init(authorId: authorId, date: date, content: content, isActive: isActive)
    }

    func setData(dictionary: [String: Any]) {
        self.content = dictionary["content"] as! String? ?? ""
        let dateTimeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        self.date = Date(timeIntervalSince1970: dateTimeIntervalDate)
        self.authorId = dictionary["author_id"] as! String? ?? ""
        self.isActive = dictionary["is_active"] as! Bool? ?? true
    }

    func save(flat: Flat?, postId: String?, completion: @escaping () -> ()) {
        guard let flatId = flat?.documentId else {
            print("🔴 DATABASE ERROR: updating post \(String(describing: documentId))")
            return completion()
        }
        guard let postId = postId else {
            print("🔴 DATABASE ERROR: updating post \(String(describing: documentId))")
            return completion()
        }
        if let documentId = documentId {
            let ref = db.collection("flats").document(flatId).collection("posts").document(postId).collection("comments").document(documentId)
            ref.setData(self.dictionary) { error in
                if let error = error {
                    print("🔴 ERROR: Updating comment \(documentId) \(error)")
                    completion()
                }

//                self.author = flat?.members?.membersArray.first(where: { $0.userId == self.authorId })
                print("🟢 DATABASE: Updated post \(String(describing: documentId))")
                completion()
            }
        } else {
            let ref = db.collection("flats").document(flatId).collection("posts").document(postId).collection("comments").document()
            ref.setData(self.dictionary) { error in
                if let error = error {
                    print("🔴 ERROR: Creating comment \(error)")
                    completion()
                }
                self.documentId = ref.documentID
//                self.author = flat?.members?.membersArray.first(where: { $0.userId == self.authorId })
                print("🟢 DATABASE: Created post \(String(describing: self.documentId))")
                completion()
            }
        }
    }
}
