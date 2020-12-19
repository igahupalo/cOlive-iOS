//
//  SignUpViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 11/09/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {

    weak var parentDelegate: StartViewController?

    private var displayNameErrorMessage = ""
    private var emailErrorMessage = ""
    private var passwordErrorMessage = ""
    private let sessionManager = SessionManager()

    private var isValidUsername: Bool {
        if let displayName = displayNameTextField.text {

            // Check if displayName is not empty.
            if displayName.isEmpty {
                displayNameErrorMessage = Constants.SignUpErrorMessages.emptyName
                return false
            }

            // Username is valid.
            displayNameErrorMessage = ""
            return true
        }
        return false
    }

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

    private var isValidPassword: Bool {
        if let password = passwordTextField.text {

            // Check if password is not empty.
            if password.isEmpty {
                passwordErrorMessage = Constants.SignUpErrorMessages.emptyPassword
                return false
            }

            // Check if password is long enough.
            if password.count < 6 {
                passwordErrorMessage = Constants.SignUpErrorMessages.shortPassword
                return false
            }

            // Password is valid.
            passwordErrorMessage = ""
            return true
        }
        return false
    }

    
    @IBOutlet weak var displayNameTextField: MaterialTextField!
    @IBOutlet weak var emailTextField: MaterialTextField!
    @IBOutlet weak var passwordTextField: MaterialTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
     }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case displayNameTextField:
            let _ = emailTextField.becomeFirstResponder()
        case emailTextField:
            let _ = passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }

    @IBAction func displayNameEditingDidEnd(_ sender: Any) {
        if !isValidUsername { displayNameTextField.setHelpText(message: displayNameErrorMessage) }
    }

    @IBAction func emailEditingDidEnd(_ sender: Any) {
        if !isValidEmail { emailTextField.setHelpText(message: emailErrorMessage) }
    }

    @IBAction func passwordEditingDidEnd(_ sender: Any) {
        if !isValidPassword { passwordTextField.setHelpText(message: passwordErrorMessage) }
    }

    @IBAction func crossButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            self?.parentDelegate?.performSegue(withIdentifier: "StartToLoginSeg", sender: nil)
        }
    }

    @IBAction func sighUpButtonTapped(_ sender: Any) {
        let displayName = displayNameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        if !isValidUsername { displayNameTextField.setError(message: displayNameErrorMessage) }
        if !isValidEmail { emailTextField.setError(message: emailErrorMessage) }
        if !isValidPassword { passwordTextField.setError(message: passwordErrorMessage) }

        if !isValidUsername || !isValidEmail || !isValidPassword {
            return
        }

        sessionManager.signUp(displayName: displayName, email: email, password: password, completionBlock: { (errorCode) in
            if errorCode == nil {
                print("User signed up successfully.")
            } else {
                switch errorCode {
                case .emailAlreadyInUse:
                    // Error: The email address is already in use by another account.
                    self.emailErrorMessage = Constants.SignUpErrorMessages.takenEmail
                    self.emailTextField.setError(message: self.emailErrorMessage)
                case .invalidEmail:
                    // Error: The email address is badly formatted.
                    self.emailErrorMessage = Constants.LoginErrorMessages.invalidEmail
                    self.emailTextField.setError(message: self.emailErrorMessage)
                case .weakPassword:
                    self.passwordErrorMessage = Constants.SignUpErrorMessages.shortPassword
                    self.passwordTextField.setError(message: self.passwordErrorMessage)
                default:
                    print("Error")
                }
            }
        })
    }
}
