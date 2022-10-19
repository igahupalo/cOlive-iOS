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

    func signUp(displayName: String, email: String, password: String, completionBlock: @escaping ((_ error: AuthErrorCode?) -> ())) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                completionBlock(AuthErrorCode(rawValue: error.code))
            } else {
                if let authResult = Auth.auth().currentUser {
                    let uid = authResult.uid
                    let user = User(uid: uid, displayName: displayName, email: email)
                    user.save { success in
                        guard success else {
                            print("🔴 DATABASE ERROR: Saving new user")
                            return
                        }
                        print("🟢 DATABASE: Saved new user")
                    }
                }
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
            print("🔴 ERROR: Signing out")
        }
    }
}
