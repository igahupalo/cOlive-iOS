//
//  TableViewCell.swift
//  cOlive
//
//  Created by Iga Hupalo on 19/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

protocol MembershipTableViewDelegate: class {
    func enterButtonTapped(cell: MembershipTableViewCell?)
}

class MembershipTableViewCell: UITableViewCell {

    @IBOutlet weak var flatNameLabel: UILabel!
    @IBOutlet weak var enterButton: UIButton!

    weak var membershipTableViewDelegate: MembershipTableViewDelegate?
    weak var membership: Membership?
    weak var user: User?

    func setContent() {
        if let membership = membership {
            self.flatNameLabel.text = membership.flat.name
            self.enterButton.isHidden = self.user?.membershipId == membership.documentId
        }
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        weak var weakSelf = self
        self.membershipTableViewDelegate?.enterButtonTapped(cell: weakSelf)
    }
}
