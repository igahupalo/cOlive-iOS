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

    @IBOutlet weak var userImageImageView: UIImageView!
    @IBOutlet weak var userGreetingLabel: UILabel!
    @IBOutlet weak var flatNameLabel: UILabel!

    private let sessionManager: SessionManager

    var user: User?

    required init?(coder: NSCoder) {
        self.sessionManager = SessionManager()
        self.user = User()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.user?.fetchCurrent {
            self.setContent()
            if self.user == nil {
                self.user?.detachListeners()
                self.sessionManager.logOut()
            }
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setContent()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.homeToFlatsSegue:
            let flatsViewController = segue.destination as! FlatsViewController
            flatsViewController.user = self.user
        case Constants.Storyboard.homeToProfileSegue:
            print("profile")
        default:
            break
        }
    }

    func setContent() {
        if let user = self.user {
            userGreetingLabel.text = "Hi, \(user.username)!"
            userImageImageView.image = user.image
            if let flat = self.user?.membership?.flat {
                flatNameLabel.text = flat.name
            }
        }
    }

    @IBAction func logOutTapped(_ sender: Any) {
        self.user?.detachListeners()
        sessionManager.logOut()
        // dettach observers
    }
}
