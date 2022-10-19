//
//  MemberTableViewCell.swift
//  cOlive
//
//  Created by Iga Hupalo on 15/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

protocol MembersTableViewDelegate: AnyObject {
    func removeButtonTapped(cell: MemberTableViewCell?)
    func leaveButtonTapped(cell: CurrentMemberTableViewCell?)
}

class MemberTableViewCell: UITableViewCell {
    @IBOutlet weak var userImageView: ProfileImageView!
    @IBOutlet weak var displayNameLabel: UILabel!

    weak var member: Member?
    weak var membersTableViewDelegate: MembersTableViewDelegate?

    func setContent() {
        displayNameLabel.text = member?.user?.displayName
        userImageView.user = member?.user
        userImageView.setContent()
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
