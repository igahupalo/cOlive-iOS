//
//  AddEventViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 12/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class EditEventViewController: UIViewController {

    @IBOutlet weak var titleTextField: MaterialTextField!
    @IBOutlet weak var desriptionTextView: MaterialTextView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var isAllDaySwitch: UISwitch!
    @IBOutlet weak var barButtonItem: UIBarButtonItem!

    var user: User?
    var flatId: String?
    var event: Event?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = event {
            self.setupEditMode()
        }
    }

    private func setupEditMode() {
        self.title = "Edit event"
        self.barButtonItem.title = "Save"
        self.titleTextField.text = self.event?.title
        self.desriptionTextView.text = self.event?.description
        self.isAllDaySwitch.isOn = self.event?.isAllDay ?? true
        self.startDatePicker.date = self.event?.startDate ?? Date()
        self.endDatePicker.date = self.event?.endDate ?? Date()

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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case titleTextField:
            let _ = desriptionTextView.becomeFirstResponder()
        case desriptionTextView:
            desriptionTextView.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
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
            if let event = self.event {
                event.setData(title: title, description: description, isAllDay: isAllDay, startDate: startDate, endDate: endDate)
            } else {
                self.event = Event(title: title, description: description, isAllDay: isAllDay, startDate: startDate, endDate: endDate, authorId: authorId, isActive: true)
            }

            self.event?.save(flatId: flatId) { [weak self] (success) in
                guard success else {
                    print("🔴 ERROR: New event not created.")
                    return
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}

