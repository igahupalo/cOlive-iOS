//
//  EditEventViewController.swift
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

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = event {
            setupEditMode()
        }
    }

    // MARK: View config

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

    // MARK: Event handlers

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

        handleAddEvent(title: title, description: description, isAllDay: isAllDay, startDate: startDate, endDate: endDate)
    }
}

// MARK: Private

private extension EditEventViewController {
    func handleAddEvent(title: String, description: String, isAllDay: Bool, startDate: Date, endDate: Date) {
        if let authorId = user?.documentId {
            if let event = event {
                event.setData(title: title, description: description, isAllDay: isAllDay, startDate: startDate, endDate: endDate)
            } else {
                event = Event(title: title, description: description, isAllDay: isAllDay, startDate: startDate, endDate: endDate, authorId: authorId, isActive: true)
            }

            event?.save(flatId: flatId) { [weak self] (success) in
                guard success else {
                    self?.showErrorAlert()
                    return
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    func showErrorAlert() {
        let alert = UIAlertController(title: Constants.AddEventErrorMessages.alertTitle, message: Constants.AddEventErrorMessages.alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: Constants.AddEventErrorMessages.alertButton, style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func setupEditMode() {
        // TODO: Constants
        title = "Edit event"
        barButtonItem.title = "Save"
        titleTextField.text = event?.title
        desriptionTextView.text = event?.description
        isAllDaySwitch.isOn = event?.isAllDay ?? true
        startDatePicker.date = event?.startDate ?? Date()
        endDatePicker.date = event?.endDate ?? Date()
    }
}
