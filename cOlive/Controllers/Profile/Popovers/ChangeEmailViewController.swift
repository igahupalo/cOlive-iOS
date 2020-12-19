//
//  ChangeEmailViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 22/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit

class ChangeEmailViewController: FormPopoverViewController {


    @IBOutlet weak var emailTextField: MaterialTextField!
    weak var user: User?

    private var emailErrorMessage = ""
    private var isValidEmail: Bool {
        if let email = emailTextField.text {
            // Check if email is not empty.
            if email.isEmpty {
                emailErrorMessage = Constants.SignUpErrorMessages.emptyEmail
                return false
            }
            // Check if email is correct.
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            if !emailPredicate.evaluate(with: email) {
                emailErrorMessage = Constants.SignUpErrorMessages.invalidEmail
                return false
            }
            // Email is valid.
            emailErrorMessage = ""
            return true
        }
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.text = user?.email
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        if self.emailTextField.isFirstResponder { self.emailTextField.resignFirstResponder() }

        if !isValidEmail {
            emailTextField.setError(message: emailErrorMessage)
            return
        }

        let email = self.emailTextField.text!
        self.user?.email = email
        let sessionManager = SessionManager()

        // Email change

        self.dismiss(animated: true, completion: nil)
    }
}
