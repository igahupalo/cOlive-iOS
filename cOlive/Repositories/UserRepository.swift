//
//  UserRepository.swift
//  cOlive
//
//  Created by Iga Hupalo on 17/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import Firebase

class UserRepository {

    // Get current user.
    func getCurrentUser(completion: @escaping (User?) -> ()) {
        var user: User?
        if let currentUser = Auth.auth().currentUser {
            Shared.db.collection("users").whereField("uid", isEqualTo: currentUser.uid).limit(to: 1).getDocuments { documentSnapshot, error in
                if let snapshot = documentSnapshot {
                    let document = snapshot.documents[0]
                    let data = document.data()
                    let username = data["username"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let firstName = data["firstName"] as? String
                    let lastName = data["lastName"] as? String
                    user =  User(uid: currentUser.uid, username: username, email: email, firstName: firstName, lastName: lastName)

                    completion(user)
                } else {
                    print("Document does not exist.")
                
                }
            }
        }
    }

    // Attach observer on current user.
    func observeUser(user: User) {
        Shared.db.collection("users").document(user.username).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            user.firstName = data["first_name"] as? String
            user.lastName = data["last_name"] as? String
            user.imageUrl = data["image_url"] as? String
        }
    }
}
