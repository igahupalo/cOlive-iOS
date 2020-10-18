//
//  StartViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 15/09/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

protocol StartViewControllerDelegate {
    func transitionToLogin()
    func transitionToSignUp()
}

class StartViewController: UIViewController, StartViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        transitionToLogin()
    }

    @IBAction func createAccountButtonTapped(_ sender: Any) {
        transitionToSignUp()
    }

    func transitionToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.loginViewController) as! LogInViewController
        loginViewController.parentDelegate = self
        self.navigationController?.present(loginViewController, animated: true)
    }

    func transitionToSignUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signUpViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.signUpViewController) as! SignUpViewController
        signUpViewController.parentDelegate = self
        self.navigationController?.present(signUpViewController, animated: true)    }
}
