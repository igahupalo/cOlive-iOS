//
//  ChangePasswordViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 22/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import UIKit

class ChangePasswordViewController: FormPopoverViewController {

    @IBOutlet weak var oldPasswordTextField: MaterialTextField!
    @IBOutlet weak var newPasswordTextField: MaterialTextField!

    weak var user: User?

    private var oldPasswordErrorMessage = ""
    private var newPasswordErrorMessage = ""

    private var isValidOldPassword: Bool {
        if let oldPassword = oldPasswordTextField.text {
            if oldPassword.count == 0 {
                oldPasswordErrorMessage = Constants.FormPopoversErrorMessages.emptyOldPassword
                return false
            }
            return true
        }
        return false
    }

    private var isValidNewPassword: Bool {
        if let newPassword = newPasswordTextField.text {
            if newPassword.count == 0 {
                newPasswordErrorMessage = Constants.FormPopoversErrorMessages.emptyNewPassword
                return false
            }
            return true
        }
        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case oldPasswordTextField:
            let _ = newPasswordTextField.becomeFirstResponder()
        case newPasswordTextField:
            let _ = newPasswordTextField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        if oldPasswordTextField.isFirstResponder { oldPasswordTextField.resignFirstResponder() }
        if newPasswordTextField.isFirstResponder { newPasswordTextField.resignFirstResponder() }

        if !isValidOldPassword { oldPasswordTextField.setError(message: oldPasswordErrorMessage) }
        if !isValidNewPassword { oldPasswordTextField.setError(message: newPasswordErrorMessage) }

        if !isValidOldPassword || !isValidNewPassword { return }

        // TODO: Change password via session manager
        dismiss(animated: true, completion: nil)
    }
}
