//
//  MemberTableViewCell.swift
//  cOlive
//
//  Created by Iga Hupalo on 15/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

protocol MembersTableViewDelegate: class {
    func removeButtonTapped(cell: MemberTableViewCell?)
    func leaveButtonTapped(cell: CurrentMemberTableViewCell?)
}

class MemberTableViewCell: UITableViewCell {

    weak var member: Member?
    weak var membersTableViewDelegate: MembersTableViewDelegate?

    @IBOutlet weak var userImageView: ProfileImageView!
    @IBOutlet weak var displayNameLabel: UILabel!

    deinit {
        print("Member cell deinit")
    }

    func setContent() {
        self.displayNameLabel.text = member?.user?.displayName
        self.userImageView.user = member?.user
        self.userImageView.setContent()
    }

    @IBAction func removeButtonTapped(_ sender: Any) {
        weak var weakSelf = self
        membersTableViewDelegate?.removeButtonTapped(cell: weakSelf)
    }
}

class CurrentMemberTableViewCell: MemberTableViewCell {

    override func setContent() {
        super.setContent()
    }
    
    @IBAction func leaveButtonTapped(_ sender: Any) {
        weak var weakSelf = self
        membersTableViewDelegate?.leaveButtonTapped(cell: weakSelf)
    }

}
