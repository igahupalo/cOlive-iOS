//
//  SessionManager.swift
//  cOlive
//
//  Created by Iga Hupalo on 12/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SessionManager {
    let db: Firestore = Firestore.firestore()

    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }

    func signUp(username: String, email: String, password: String, completionBlock: @escaping ((_ error: AuthErrorCode?) -> ())) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                completionBlock(AuthErrorCode(rawValue: error.code))
            } else {
                completionBlock(nil)
            }
        }
    }

    func logIn(email: String, password: String, completionBlock: @escaping ((_ errorCode: AuthErrorCode?) -> ())) {
        if Auth.auth().currentUser == nil {
            Auth.auth().signIn(withEmail: email, password: password, completion: {(authResult, error) in
                if let error = error as NSError? {
                    completionBlock(AuthErrorCode(rawValue: error.code))
                } else {
                    completionBlock(nil)
                }
            })
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("*** Error: Sign out error.")
        }
    }

    func getCurrentUser(completion: @escaping (User?) -> ()) {
        var user: User?
        if let currentUser = Auth.auth().currentUser {
            db.collection("users").whereField("uid", isEqualTo: currentUser.uid).limit(to: 1).addSnapshotListener { documentSnapshots, error in
                guard error == nil else {
                    print("*** Error: \(String(describing: error?.localizedDescription))")
                    return
                }

                guard documentSnapshots != nil else {
                    print("*** Error: Document does not exist.")
                    return
                }

                guard documentSnapshots!.documents.count == 1 else {
                    print("*** Error: More than one current user.")
                    return
                }

                let document = documentSnapshots!.documents[0]
                user = User(dictionary: document.data())
                user?.documentId = document.documentID
                completion(user)
            }
        }
    }
}
