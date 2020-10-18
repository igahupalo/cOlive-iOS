//
//  HomeViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 11/09/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController {

    private let sessionManager = SessionManager()
    private var currentUser: User? = nil
    private let userRepository = UserRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        userRepository.getCurrentUser { [self] currentUser in
            self.currentUser = currentUser
            userRepository.observeUser(user: self.currentUser!)

            
        }
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        sessionManager.logOut()
        // dettach observers
    }

    // Attach listener on current user.
    

}
