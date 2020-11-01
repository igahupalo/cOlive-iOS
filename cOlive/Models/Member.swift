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
//    var expenses: Expense
//    var notes: Note
//    var events: Event

    var dictionary: [String: Any] {
        return ["userId": self.userId, "isActive": self.isActive]
    }

    init(userId: String, isActive: Bool) {
        self.userId = userId
        self.isActive = isActive
    }

    convenience init(dictionary: [String: Any]) {
        let userId = dictionary["userId"] as! String? ?? ""
        let isActive = dictionary["isActive"] as! Bool? ?? true

        self.init(userId: userId, isActive: isActive)
    }
}
