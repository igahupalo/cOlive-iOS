//
//  ViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 09/09/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {

    private var emailErrorMessage = ""
    private var passwordErrorMessage = ""
    var parentDelegate: StartViewController?

    private let sessionManager = SessionManager()

    @IBOutlet weak var emailTextField: MaterialTextField!
    @IBOutlet weak var passwordTextField: MaterialTextField!

    private var isValidEmail: Bool {
        if let email = emailTextField.text {
            if email.isEmpty {
                emailErrorMessage = Constants.LoginErrorMessages.emptyEmail
                return false
            }

            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)

            if !emailPredicate.evaluate(with: email) {
                emailErrorMessage = Constants.LoginErrorMessages.invalidEmail
                return false
            }
            emailErrorMessage = ""
            return true
        }
        return false
    }

    private var isValidPassword: Bool {
        if let password = passwordTextField.text {
            if password.isEmpty {
                passwordErrorMessage = Constants.LoginErrorMessages.emptyPassword
                return false
            }
            passwordErrorMessage = ""
            return true
        }
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
     }

    func setupElements() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    @IBAction func crossButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        if !isValidEmail { emailTextField.setError(message: emailErrorMessage) }
        if !isValidPassword { passwordTextField.setError(message: passwordErrorMessage) }

        if !isValidEmail || !isValidPassword {
            return
        }

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

