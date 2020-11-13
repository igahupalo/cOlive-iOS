//
//  AddEventViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 12/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class AddEventViewController: UIViewController {

    @IBOutlet weak var titleTextField: MaterialTextField!
    @IBOutlet weak var desriptionTextView: MaterialTextView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var isAllDaySwitch: UISwitch!

    var user: User?
    var flat: Flat?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func isWholeDayDidChange(_ sender: Any) {
        if isAllDaySwitch.isOn {
            startDatePicker.datePickerMode = .date
            endDatePicker.datePickerMode = .date
        } else {
            startDatePicker.datePickerMode = .dateAndTime
            endDatePicker.datePickerMode = .dateAndTime
        }
    }

    @IBAction func titleEditingDidEnd(_ sender: Any) {
        if titleTextField.text == "" {
            titleTextField.setHelpText(message: Constants.AddEventErrorMessages.emptyEventTitle)
        }
    }

    @IBAction func startDateEditingDidEnd(_ sender: Any) {
        if endDatePicker.date < startDatePicker.date {
            endDatePicker.date = startDatePicker.date
        }
    }

    @IBAction func endDateEditingDidEnd(_ sender: Any) {
        if endDatePicker.date < startDatePicker.date {
            startDatePicker.date = endDatePicker.date
        }
    }

    @IBAction func addEventTapped(_ sender: Any) {
        if titleTextField.text == "" {
            titleTextField.setError(message: Constants.AddEventErrorMessages.emptyEventTitle)
            return
        }

        let title = titleTextField.text ?? ""
        let description = desriptionTextView.text ?? ""
        let isAllDay = isAllDaySwitch.isOn
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date

        if let authorId = user?.documentId {
            let event = Event(title: title, description: description, isAllDay: isAllDay, startDate: startDate, endDate: endDate, authorId: authorId, isActive: true)

            if let flat = self.flat {
                event.save(flat: flat) { (success) in
                    guard success else {
                        print("🔴 ERROR: New event not created.")
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }

    }
}

