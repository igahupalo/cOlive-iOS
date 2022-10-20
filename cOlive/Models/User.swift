//
//  User.swift
//  cOlive
//
//  Created by Iga Hupalo on 16/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import UIKit

class User {
    var documentId: String?
    var uid: String
    var displayName: String
    var email: String
    var phoneNumber: String?
    var birthday: Date?
    var membershipId: String?
    var membership: Membership?
    var imageUrl: String?
    var image: UIImage?

    var dictionary: [String: Any] {
        let dictionary: [String: Any?] =  ["uid": uid,
                                           "display_name": displayName,
                                           "email": email,
                                           "phone_number": phoneNumber,
                                           "birthday": birthday,
                                           "image_url": imageUrl,
                                           "membership_id": membershipId]
        return dictionary.filter { $0.value != nil } .mapValues { $0! }
    }

    // MARK: Inits

    init(uid: String, displayName: String, email: String, phoneNumber: String?, birthday: Date?, imageUrl: String?, membershipId: String?) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
        self.phoneNumber = phoneNumber
        self.birthday = birthday
        self.imageUrl = imageUrl
        self.membershipId = membershipId
    }

    convenience init(documentId: String) {
        self.init(uid: "", displayName: "", email: "", phoneNumber: nil, birthday: nil, imageUrl: nil, membershipId: nil)
        self.documentId = documentId
    }

    convenience init() {
        self.init(uid: "", displayName: "", email: "", phoneNumber: nil, birthday: nil, imageUrl: nil, membershipId: nil)
    }

    convenience init(uid: String, displayName: String, email: String) {
        let uid = uid
        let displayName = displayName
        let email = email

        self.init(uid: uid, displayName: displayName, email: email, phoneNumber: nil, birthday: nil, imageUrl: nil, membershipId: nil)
    }

    convenience init(dictionary: [String: Any]) {
        let uid = dictionary["uid"] as! String? ?? ""
        let displayName = dictionary["display_name"] as! String? ?? ""
        let email = dictionary["email"] as! String? ?? ""
        let phoneNumber = dictionary["phone_number"] as! String?
        let timeIntervalDate = dictionary["birthday"] as! TimeInterval? ?? TimeInterval()
        let birthday = Date(timeIntervalSince1970: timeIntervalDate)
        let imageUrl = dictionary["image_url"] as! String?
        let membershipId = dictionary["membership_id"] as! String?

        self.init(uid: uid, displayName: displayName, email: email, phoneNumber: phoneNumber, birthday: birthday, imageUrl: imageUrl, membershipId: membershipId)
    }

    deinit {
        print("🟦 user deinit")
    }

    func setData(dictionary: [String: Any]) {
        uid = dictionary["uid"] as! String? ?? ""
        displayName = dictionary["display_name"] as! String? ?? ""
        email = dictionary["email"] as! String? ?? ""
        phoneNumber = dictionary["phone_number"] as! String?
        imageUrl = dictionary["image_url"] as! String?
        membershipId = dictionary["membership_id"] as! String?

        let birthdayTimeInterval = dictionary["birthday"] as! TimeInterval?
        if let birthdayTimeInterval = birthdayTimeInterval {
            birthday = Date(timeIntervalSince1970: birthdayTimeInterval)
        }
    }
}
