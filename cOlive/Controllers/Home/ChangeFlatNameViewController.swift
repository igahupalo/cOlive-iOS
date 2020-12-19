//
//  ChangeFlatNameViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 28/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

protocol ChangeFlatNameDelegate: class {
    func updateFlatName()
}

class ChangeFlatNameViewController: FormPopoverViewController {

    @IBOutlet weak var flatNameTextField: MaterialTextField!

    weak var flat: Flat?
    weak var changeFlatNameDelegate: ChangeFlatNameDelegate?

    private var flatNameErrorMessage = ""

    private var isValidFlatName: Bool {
        if flatNameTextField.text?.count == 0 {
            flatNameErrorMessage = Constants.FormPopoversErrorMessages.emptyFlatName
            return false
        }
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.flatNameTextField.text = flat?.name
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        if self.flatNameTextField.isFirstResponder { self.flatNameTextField.resignFirstResponder() }

        if !isValidFlatName {
            flatNameTextField.setError(message: flatNameErrorMessage)
            return
        }

        let name = flatNameTextField.text!
        self.flat?.name = name
        self.flat?.saveName { [weak self] in

            self?.dismiss(animated: true) {
                self?.changeFlatNameDelegate?.updateFlatName()
            }
        }
    }

}
