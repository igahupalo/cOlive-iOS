//
//  AddFlatViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 18/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class AddFlatViewController: UIViewController {

    var currentUser: User?
    var memberships: Memberships?

    @IBOutlet weak var flatPhotoImageView: UIImageView!
    @IBOutlet weak var flatNameTextField: MaterialTextField!

    private var flatNameErrorMessage: String = ""
    private var imagePicker: ImagePicker!

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

        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }

    @IBAction func selectPhotoTapped(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }

    @IBAction func addFlatTapped(_ sender: Any) {
        // Validate data.
        if !isValidFlatName {
            flatNameTextField.setError(message: flatNameErrorMessage)
            return
        }

        let flatName = flatNameTextField.text!
        guard let currentUser = self.currentUser else {
            print("🔴 ERROR: No logged user to assign to the new flat.")
            return
        }

        guard let currentUserId = currentUser.documentId else {
            print("🔴 ERROR: No user id to assign to the new flat.")
            return
        }

        // Create flat.
        let flat = Flat(name: flatName, ownerId: currentUserId, isActive: true, image: flatPhotoImageView.image)

        // Save flat.
        flat.saveData { flatSuccess in
            // Create membership.
            guard flatSuccess else {
                print("🔴 ERROR: No flat to assign to the new membership.")
                return
            }
            guard let documentId = flat.documentId else {
                print("🔴 ERROR: No flat id to assign to the new membership.")
                return
            }

            // Create membership
            let membership = Membership(flatId: documentId, lastUsed: Date(), type: Membership.MembershipType.owner)

            membership.saveData(user: currentUser) { membershipSuccess in
                guard membershipSuccess else {
                    print("🔴 ERROR: No membership created.")
                    // Delete created flat, that was suppsed to be assigned to the membership.
                    flat.delete()
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension AddFlatViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        self.flatPhotoImageView.image = image
    }
}
