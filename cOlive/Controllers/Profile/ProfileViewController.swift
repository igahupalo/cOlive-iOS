//
//  ProfileViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 25/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    var user: User? = nil
    private let sessionManager: SessionManager

    required init?(coder: NSCoder) {
        self.sessionManager = SessionManager()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func logOutTapped(_ sender: Any) {
        self.user?.detachListeners()
        sessionManager.logOut()
    }

}
