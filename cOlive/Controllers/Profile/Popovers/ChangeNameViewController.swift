//
//  ChangeNameViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 22/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

protocol ChangeNameDelegate: class {
    func updateDisplayName()
}

class ChangeNameViewController: FormPopoverViewController {

    @IBOutlet weak var nameTextField: MaterialTextField!

    weak var user: User?
    weak var changeNameDelegate: ChangeNameDelegate?

    private var nameErrorMessage = ""
    private var isValidName: Bool {
        if nameTextField.text?.count == 0 {
            nameErrorMessage = Constants.FormPopoversErrorMessages.emptyName
            return false
        }
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.text = user?.displayName
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        if self.nameTextField.isFirstResponder { self.nameTextField.resignFirstResponder() }

        if !isValidName {
            nameTextField.setError(message: nameErrorMessage)
            return
        }

        let name = nameTextField.text!
        self.user?.displayName = name
        self.user?.saveDisplayName { [weak self] in
            
            self?.dismiss(animated: true) {
                self?.changeNameDelegate?.updateDisplayName()
            }
        }
    }
}

