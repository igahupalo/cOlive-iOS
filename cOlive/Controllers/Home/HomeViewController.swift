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

    private let sessionManager: SessionManager
    private var currentUser: User?

    required init?(coder: NSCoder) {
        self.sessionManager = SessionManager()
        self.currentUser = nil
        super.init(coder: coder)

        self.sessionManager.getCurrentUser { user in
            self.currentUser = user
            if user == nil {
                self.sessionManager.logOut()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.homeToFlatsSegue:
            let flatsViewController = segue.destination as! FlatsViewController
            flatsViewController.currentUser = self.currentUser
        case Constants.Storyboard.homeToProfileSegue:
            print("profile")
        default:
            break
        }
    }

    @IBAction func logOutTapped(_ sender: Any) {
        sessionManager.logOut()
        // dettach observers
    }
}
