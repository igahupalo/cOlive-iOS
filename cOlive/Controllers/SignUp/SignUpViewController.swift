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
    private let db: Firestore = Firestore.firestore()

    private var usernameErrorMessage = ""
    private var emailErrorMessage = ""
    private var passwordErrorMessage = ""
    private let sessionManager = SessionManager()
    internal var parentDelegate: StartViewControllerDelegate? = nil

    private var isValidUsername: Bool {
        if let username = usernameTextField.text {

            // Check if username is not empty.
            if username.isEmpty {
                usernameErrorMessage = Constants.SignUpErrorMessages.emptyUsername
                return false
            }

            // Check if username is taken.
            // ...


            // Username is valid.
            usernameErrorMessage = ""
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
                emailErrorMessage = Constants.LoginErrorMessages.invalidEmail
                return false
            }

            // Check if email is not already in use.

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

    @IBOutlet weak var usernameTextField: MaterialTextField!
    @IBOutlet weak var emailTextField: MaterialTextField!
    @IBOutlet weak var passwordTextField: MaterialTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
     }

    func setupElements() {
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
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

    @IBAction func usernameEditingDidEnd(_ sender: Any) {
        if !isValidUsername { usernameTextField.setHelpText(message: usernameErrorMessage) }
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
        self.dismiss(animated: true) {
            self.parentDelegate?.transitionToLogin()
        }
    }

    @IBAction func sighUpButtonTapped(_ sender: Any) {
        let username = usernameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        if !isValidUsername { usernameTextField.setError(message: usernameErrorMessage) }
        if !isValidEmail { emailTextField.setError(message: emailErrorMessage) }
        if !isValidPassword { passwordTextField.setError(message: passwordErrorMessage) }

        if !isValidUsername || !isValidEmail || !isValidPassword {
            return
        }

        sessionManager.signUp(username: username, email: email, password: password, completionBlock: { (errorCode) in
            if errorCode == nil {
                if let authResult = Auth.auth().currentUser {
                    let uid = authResult.uid
                    self.createUser(uid: uid, username: username, email: email)
                }
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

    // MARK: Database queries.

    // Create user.
    private func createUser(uid: String, username: String, email: String) {
        let usersRef = db.collection("users")
        usersRef.document().setData(["uid": uid, "username": username, "email": email], merge: true)
    }
}
