//
//  User.swift
//  cOlive
//
//  Created by Iga Hupalo on 16/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore

class User {
    let db: Firestore = Firestore.firestore()
    var documentId: String?

    var uid: String
    var username: String
    var email: String
    var firstName: String?
    var lastName: String?
//    var imageUrl: String?
    
    var dictionary: [String: Any] {
        let dictionary =  ["uid": uid, "username": username, "email": email, "firstName": firstName != nil ? firstName : nil, "lastName": lastName != nil ? lastName : nil]
        return dictionary.filter { $0.value != nil }.mapValues { $0! }
    }

    init(uid: String, username: String, email: String) {
        self.uid = uid
        self.username = username
        self.email = email
    }

    init(uid: String, username: String, email: String, firstName: String?, lastName: String?) {
        self.uid = uid
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }

    convenience init(dictionary: [String: Any]) {
        let uid = dictionary["uid"] as! String? ?? ""
        let username = dictionary["username"] as! String? ?? ""
        let email = dictionary["email"] as! String? ?? ""
        let firstName = dictionary["firstName"] as! String? ?? ""
        let lastName = dictionary["lastName"] as! String? ?? ""

        self.init(uid: uid, username: username, email: email, firstName: firstName, lastName: lastName)
    }


}
