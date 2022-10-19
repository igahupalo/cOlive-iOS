//
//  RemoveUserViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 17/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class RemoveUserViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!

    weak var member: Member?
    weak var flat: Flat?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Add constants
        titleLabel.text = "Remove \(member?.user?.displayName ?? "the user")?"
        subtitleLabel.text = "Are you sure you want to remove \(member?.user?.displayName ?? "the user") from your flat group?"
        subtitleLabel.text = "\(member?.user?.displayName ?? "The user") will still be able to check-in in the apartment. Their posts and events will stay visible. Their balance with all the other members is going to be marked as settled up."
    }

    // MARK: - Event handlers

    @IBAction func removeButtonTapped(_ sender: Any) {
        if let flat = flat {
            self.member?.removeFrom(flat: flat) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
