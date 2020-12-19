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
    var invitationCode: InvitationCode?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.shareButton.isEnabled = false
        self.shareButton.alpha = 0.5
        self.flatNameLabel.text = flat?.name

        if let flatId = self.flat?.documentId {
            self.invitationCode = InvitationCode(flatId: flatId)
            self.invitationCode?.generate() {
                self.invitationCodeActivityIndicator.stopAnimating()
                self.invitationCodeLabel.text = self.invitationCode?.code
                self.invitationCodeLabel.isHidden = false
                self.shareButton.alpha = 1
                self.shareButton.isEnabled = true
            }
        }
    }

    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let code = invitationCode?.code else {
            return
        }


        let shareImage = UIImage(named: "logo.background") ?? UIImage()
        let shareMessage = "I invite you to share \(flat?.name ?? "a") flat group with me in cOlive app. You can check-in using code: \(code)"

        let textToShare = [shareImage, shareMessage] as [Any]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
