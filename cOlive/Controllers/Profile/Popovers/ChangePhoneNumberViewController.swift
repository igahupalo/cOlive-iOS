//
//  ChangePhoneNumberViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 22/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import UIKit

protocol ChangePhoneNumberDelegate: class {
    func updatePhoneNumber()
}

class ChangePhoneNumberViewController: FormPopoverViewController {

    @IBOutlet weak var phoneNumberTextField: MaterialTextField!

    weak var user: User?
    weak var changePhoneNumberDelegate: ChangePhoneNumberDelegate?

    private var phoneNumberErrorMessage = ""
    private var isValidPhoneNumber: Bool {
        // TODO: phone number validation
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneNumberTextField.text = user?.phoneNumber
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        if self.phoneNumberTextField.isFirstResponder { self.phoneNumberTextField.resignFirstResponder() }

        if !isValidPhoneNumber {
            phoneNumberTextField.setError(message: phoneNumberErrorMessage)
            return
        }

        let phoneNumber = phoneNumberTextField.text
        self.user?.phoneNumber = phoneNumber ?? nil
        self.user?.savePhoneNumber { [weak self] in
            self?.dismiss(animated: true) {
                self?.changePhoneNumberDelegate?.updatePhoneNumber()
            }
        }
    }
}
