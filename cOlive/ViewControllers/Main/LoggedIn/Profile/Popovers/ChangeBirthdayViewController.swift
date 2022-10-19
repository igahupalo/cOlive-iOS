//
//  ChangeBirthdayViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 22/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import UIKit

protocol ChangeBirthdayDelegate: class {
    func updateBirthday()
}

class ChangeBirthdayViewController: FormPopoverViewController {
    @IBOutlet weak var birthdayDatePicker: UIDatePicker!

    weak var changeBirthdayDelegate: ChangeBirthdayDelegate?
    weak var user: User?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupContent()
    }

    // MARK: - Event handlers

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        let birthday = birthdayDatePicker.date
        user?.birthday = birthday
        user?.saveBirthday { [weak self] in
            self?.dismiss(animated: true) {
                self?.changeBirthdayDelegate?.updateBirthday()
            }
        }
    }

    // MARK: - Private

    private func setupContent() {
        birthdayDatePicker.maximumDate = Date()
        if let birthdayDate = user?.birthday {
            self.birthdayDatePicker.date = birthdayDate
        }
    }
}
