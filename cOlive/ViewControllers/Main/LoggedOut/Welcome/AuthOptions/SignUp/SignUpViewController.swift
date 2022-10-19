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
    @IBOutlet weak var displayNameTextField: MaterialTextField!
    @IBOutlet weak var emailTextField: MaterialTextField!
    @IBOutlet weak var passwordTextField: MaterialTextField!

    weak var parentDelegate: AuthOptionsViewController?

    private var displayNameErrorMessage = ""
    private var emailErrorMessage = ""
    private var passwordErrorMessage = ""
    private let sessionManager = SessionManager()
    private let validator = Validator()
    private var isValidDisplayName: Bool { validateDisplayName() }
    private var isValidEmail: Bool { validateEmail() }
    private var isValidPassword: Bool { validatePassword() }

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

    // MARK: Events handlers.

    @IBAction func displayNameEditingDidEnd(_ sender: Any) {
        if !isValidDisplayName { displayNameTextField.setHelpText(message: displayNameErrorMessage) }
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

        handleSignUp(displayName: displayName, email: email, password: password)
    }
}

private extension SignUpViewController {
    func handleSignUp(displayName: String, email: String, password: String) {
        if validateInputData() {
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

    func validateInputData() -> Bool {
        if !isValidDisplayName { displayNameTextField.setError(message: displayNameErrorMessage) }
        if !isValidEmail { emailTextField.setError(message: emailErrorMessage) }
        if !isValidPassword { passwordTextField.setError(message: passwordErrorMessage) }

        return isValidDisplayName && isValidEmail && isValidPassword
    }

     func validateDisplayName() -> Bool {
         let validationResponse = validator.validateDisplayName(displayNameTextField.text)
         switch validationResponse {
         case .empty:
             displayNameErrorMessage = Constants.SignUpErrorMessages.emptyName
             return false
         default:
             displayNameErrorMessage = ""
             return true
         }
    }

    func validateEmail() -> Bool {
        let validationResponse = validator.validateEmail(emailTextField.text)
        switch validationResponse {
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

    func validatePassword() -> Bool {
        let validationResponse = validator.validatePassword(passwordTextField.text)
        switch validationResponse {
        case .empty:
            passwordErrorMessage = Constants.SignUpErrorMessages.emptyEmail
            return false
        case .short:
            passwordErrorMessage = Constants.SignUpErrorMessages.shortPassword
            return false
        default:
            passwordErrorMessage = ""
            return true
        }
    }
}
