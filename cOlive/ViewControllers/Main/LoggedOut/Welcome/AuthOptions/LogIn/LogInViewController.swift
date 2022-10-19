//
//  ViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 09/09/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: MaterialTextField!
    @IBOutlet weak var passwordTextField: MaterialTextField!

    private var emailErrorMessage = ""
    private var passwordErrorMessage = ""
    private let sessionManager = SessionManager()
    private let validator = Validator()
    private var isValidEmail: Bool { validateEmail() }
    private var isValidPassword: Bool { validatePassword() }
    weak var parentDelegate: AuthOptionsViewController?

    // MARK: Events handlers.

    @IBAction func crossButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        handleLogin(email: email, password: password)
    }

    // MARK: TextField events handlers.

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case emailTextField:
                let _ = passwordTextField.becomeFirstResponder()
            case passwordTextField:
                passwordTextField.resignFirstResponder()
            default:
                textField.resignFirstResponder()
        }
        return false
    }

    @IBAction func emailEditingDidEnd(_ sender: Any) {
        if !isValidEmail { emailTextField.setHelpText(message: emailErrorMessage) }
    }

    @IBAction func passwordEditingDidEnd(_ sender: Any) {
        if !isValidPassword { passwordTextField.setHelpText(message: passwordErrorMessage) }
    }

    @IBAction func signUpButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            self?.parentDelegate?.performSegue(withIdentifier: "StartToSignUpSeg", sender: nil)
        }
    }
}

private extension LogInViewController {
    func handleLogin(email: String, password: String) {
        if validateData() {
            sessionManager.logIn(email: email, password: password, completionBlock: { (errorCode) in
                if errorCode == nil {
                    print("User logged in successfully.")
                } else {
                    switch errorCode! {
                    case .wrongPassword:
                        // Error: The password is invalid or the user does not have a password.
                        self.emailErrorMessage = Constants.LoginErrorMessages.incorrectEmailPassword
                        self.passwordErrorMessage = Constants.LoginErrorMessages.incorrectEmailPassword
                        self.emailTextField.setError(message: self.emailErrorMessage)
                        self.passwordTextField.setError(message: self.passwordErrorMessage)
                    case .invalidEmail:
                        // Error: Indicates the email address is malformed.
                        self.emailErrorMessage = Constants.LoginErrorMessages.invalidEmail
                        self.emailTextField.setError(message: self.emailErrorMessage)
                    default:
                        print("Error")
                    }
                }
            })
        }
    }

    func validateData() -> Bool {
        if !isValidEmail { emailTextField.setError(message: emailErrorMessage) }
        if !isValidPassword { passwordTextField.setError(message: passwordErrorMessage) }
        return isValidEmail && isValidPassword
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
        default:
            passwordErrorMessage = ""
            return true
        }
    }
}
