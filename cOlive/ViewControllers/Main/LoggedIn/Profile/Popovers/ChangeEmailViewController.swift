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
            let validator = Validator()
            switch validator.validateEmail(email) {
            case .empty:
                emailErrorMessage = Constants.SignUpErrorMessages.emptyEmail
                return false
            case .incorrect:
                emailErrorMessage = Constants.SignUpErrorMessages.invalidEmail
                return false
            default:
                emailErrorMessage = ""
                return true
            }
        }
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = user?.email
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        if emailTextField.isFirstResponder { emailTextField.resignFirstResponder()
        }

        if !isValidEmail {
            emailTextField.setError(message: emailErrorMessage)
            return
        }

        user?.email = emailTextField.text!
        let sessionManager = SessionManager()

        // TODO: Email change via session manager

        dismiss(animated: true, completion: nil)
    }
}
