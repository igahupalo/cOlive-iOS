//
//  MemberTableViewCell.swift
//  cOlive
//
//  Created by Iga Hupalo on 15/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class MemberTableViewCell: UITableViewCell {

    var member: Member?

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!

    func setContent() {
        self.usernameLabel.text = member?.user.username
        self.userImageView.image = member?.user.image
    }

}

class CurrentMemberTableViewCell: MemberTableViewCell {

    override func setContent() {
        super.setContent()
        self.usernameLabel.text = "\(String(describing: usernameLabel.text)) (you)"
        self.removeButton.setTitle("Leave", for: .normal)
    }

}
