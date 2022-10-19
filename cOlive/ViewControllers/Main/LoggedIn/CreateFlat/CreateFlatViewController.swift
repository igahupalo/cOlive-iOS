//
//  CreateFlatViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 17/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

protocol ListenerDetacherDelegate: AnyObject {
    func detachListeners()
    func detachMembershipsListener()
}

class CreateFlatViewController: UIViewController {
    @IBOutlet weak var flatNameTextField: MaterialTextField!
    @IBOutlet weak var flatAddressTextView: MaterialTextView!

    var flat: Flat?
    weak var user: User?
    weak var listenerDetacherDelegate: ListenerDetacherDelegate?
    private var flatNameErrorMessage: String = ""

    // MARK: - Lifecycle

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.createFlatToInviteSegue:
            let inviteViewController = segue.destination as! InviteViewController
            inviteViewController.flat = flat
        default:
            break
        }
    }

    // MARK: - Event handlers

    @IBAction func createButtonTapped(_ sender: Any) {
        let flatName = flatNameTextField.text!
        let flatAddress = flatAddressTextView.text

        handleCreateFlat(flatName: flatName, flatAddress: flatAddress)
    }
}

private extension CreateFlatViewController {
    func handleCreateFlat(flatName: String, flatAddress: String?) {
        guard let user = user else { return }
        guard let userId = user.documentId else { return }

        if !validateFlatName() {
            flatNameTextField.setError(message: flatNameErrorMessage)
            return
        }

        flat = Flat(name: flatName, ownerId: userId, address: flatAddress, isActive: true)

        flat?.create(owner: user) { [weak self] (success) in
            guard success else { return }
            self?.listenerDetacherDelegate?.detachMembershipsListener()
            self?.performSegue(withIdentifier: Constants.Storyboard.createFlatToInviteSegue, sender: self)
        }
    }

    func validateFlatName() -> Bool {
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
}
