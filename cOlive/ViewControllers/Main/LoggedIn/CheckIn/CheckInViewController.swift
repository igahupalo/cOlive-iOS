//
//  CheckInViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 14/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit
import KKPinCodeTextField

class CheckInViewController: UIViewController {
    @IBOutlet weak var invitationCodeTextField: KKPinCodeTextField!
    @IBOutlet weak var invitationCodeErrorLabel: UILabel!

    weak var user: User?
    weak var listenerDetacherDelegate: ListenerDetacherDelegate?

    private var invitationCodeErrorMessage = ""

    // MARK: Event handlers

    @IBAction func invitationCodeEditingDidBegin(_ sender: Any) {
        invitationCodeErrorLabel.text = ""
        invitationCodeErrorLabel.isHidden = true
    }

    @IBAction func invitationCodeEditingChanged(_ sender: Any) {
        if invitationCodeTextField.text?.count == 5 {
            invitationCodeTextField.resignFirstResponder()
        }
    }

    @IBAction func checkInButtonTapped(_ sender: Any) {
        guard let code = invitationCodeTextField.text else { return }
        handleCheckIn(code: code)
    }
}

// MARK: UITextFieldDelegate

extension CheckInViewController: UITextFieldDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let paste = UIPasteboard.general.string, text == paste {
            self.invitationCodeTextField.text = text
        }
        return true
    }
}

// MARK: Private

private extension CheckInViewController {
    func handleCheckIn(code: String) {
        if !validateCode() {
            invitationCodeErrorMessage = Constants.CheckInErrorMessages.shortCode
            setError()
            return
        }

        user?.checkIn(code: code) { [weak self] (error) in
            if let error = error {
                switch error {
                case .alreadyMember:
                    self?.invitationCodeErrorLabel.text = Constants.CheckInErrorMessages.alreadyMember
                case .invalidCode:
                    self?.invitationCodeErrorLabel.text = Constants.CheckInErrorMessages.invalidCode
                }
                self?.setError()
                return
            }
            self?.listenerDetacherDelegate?.detachMembershipsListener()
            self?.navigationController?.popViewController(animated: true)
        }
    }

    func validateCode() -> Bool {
        guard let code = invitationCodeTextField.text else {
            return false
        }
        return code.count == 5
    }

    func setError() {
        invitationCodeErrorLabel.text = invitationCodeErrorMessage
        invitationCodeErrorLabel.isHidden = false
        invitationCodeTextField.wiggle()
        invitationCodeTextField.wiggle()
    }
}
