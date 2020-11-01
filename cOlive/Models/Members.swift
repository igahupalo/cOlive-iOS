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
    var members: [Membership]
    var flatId: String?

    init() {
        self.members = []
    }

    func fetchData(flat: Flat, completion: @escaping (Bool) -> ()) {
        // fetch memberships
    }

    func saveData(completion: @escaping (Bool) -> ()) {
        // save array to users membership collection
    }
}
