//
//  User.swift
//  cOlive
//
//  Created by Iga Hupalo on 16/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation

class User {
    internal var uid: String
    internal var username: String
    internal var email: String
    internal var firstName: String?
    internal var lastName: String?
    internal var imageUrl: String?

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
}
