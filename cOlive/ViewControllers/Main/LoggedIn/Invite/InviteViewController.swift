//
//  InviteMembersViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 17/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class InviteViewController: UIViewController {
    @IBOutlet weak var flatNameLabel: UILabel!
    @IBOutlet weak var invitationCodeLabel: UILabel!
    @IBOutlet weak var invitationCodeActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var shareButton: UIButton!

    weak var flat: Flat?
    private var invitationCode: InvitationCode?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        disableButton()

        if let flatId = flat?.documentId {
            invitationCode = InvitationCode(flatId: flatId)
            invitationCode?.generate() {
                self.invitationCodeActivityIndicator.stopAnimating()
                self.invitationCodeLabel.text = self.invitationCode?.code
                self.enableButton()
            }
        }
    }

    // MARK: - Event handler

    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let code = invitationCode?.code else { return }

        let shareImage = UIImage(named: "logo.background") ?? UIImage()
        let shareMessage = String(format: Constants.InviteTexts.shareMessage, arguments: [flat?.name ?? "a", code])
        let textToShare = [shareImage, shareMessage] as [Any]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        self.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - Private

private extension InviteViewController {
    func disableButton() {
        shareButton.isEnabled = false
        shareButton.alpha = 0.5
        flatNameLabel.text = flat?.name
    }

    func enableButton() {
        invitationCodeLabel.isHidden = false
        shareButton.alpha = 1
        shareButton.isEnabled = true
    }
}
