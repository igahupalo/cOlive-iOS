//
//  CreateFlatViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 17/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class CreateFlatViewController: UIViewController {

    @IBOutlet weak var flatNameTextField: MaterialTextField!
    @IBOutlet weak var flatAddressTextView: MaterialTextView!

    weak var user: User?
    var flat: Flat?
    weak var listenerDetacherDelegate: ListenerDetacherDelegate?

    private var flatNameErrorMessage: String = ""

    private var isValidFlatName: Bool {
        if let flatName = flatNameTextField.text {
            if flatName.isEmpty {
                flatNameErrorMessage = Constants.AddFlatErrorMessages.emptyFlatName
                return false
            }
            flatNameErrorMessage = ""
            return true
        }
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.createFlatToInviteSegue:
            let inviteViewController = segue.destination as! InviteViewController
            inviteViewController.flat = self.flat
        default:
            break
        }
    }

    @IBAction func createButtonTapped(_ sender: Any) {
        // Validate data.
        if !isValidFlatName {
            flatNameTextField.setError(message: flatNameErrorMessage)
            return
        }

        let flatName = flatNameTextField.text!
        let flatAddress = flatAddressTextView.text
        guard let user = self.user else {
            print("🔴 ERROR: No logged user to assign to the new flat.")
            return
        }

        guard let userId = user.documentId else {
            print("🔴 ERROR: No user id to assign to the new flat.")
            return
        }

        // Create flat.
        self.flat = Flat(name: flatName, ownerId: userId, address: flatAddress, isActive: true)

        // Save flat.
        flat?.create(owner: user) { [weak self] (success) in
            guard success else {
                print("🔴 ERROR: New flat and membership not created.")
                return
            }
            self?.listenerDetacherDelegate?.detachMembershipsListener()
            self?.performSegue(withIdentifier: Constants.Storyboard.createFlatToInviteSegue, sender: self)
        }
    }
}
