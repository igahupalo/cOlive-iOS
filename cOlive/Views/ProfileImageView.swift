//
//  ProfileImageView.swift
//  cOlive
//
//  Created by Iga Hupalo on 21/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class ProfileImageView: UIView {

    var hasEditIcon: Bool = false {
        didSet {
            self.editImageView.isHidden = !self.hasEditIcon
        }
    }

    weak var user: User? {
        didSet {
            self.setContent()
        }
    }

    @IBOutlet weak var userImageImageView: UIImageView!
    @IBOutlet weak var userInitialsLabel: UILabel!
    @IBOutlet weak var editImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialization()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialization()
    }

    func initialization() {
        let view = UINib(nibName: "ProfileImageView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }

    func setContent() {

        if let user = user {
            if let image = user.image {
                self.userImageImageView.layer.cornerRadius = self.bounds.height / 2
                self.userImageImageView.image = image
                self.userInitialsLabel.isHidden = true
                self.userImageImageView.isHidden = false

            } else {
                self.userInitialsLabel.layer.cornerRadius = self.bounds.height / 2
                let initials = user.displayName.components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.first!)") + "\($1.first!)" }.uppercased()
                self.userInitialsLabel.text = initials
                self.userImageImageView.isHidden = true
                self.userInitialsLabel.isHidden = false
            }
        } else {
            self.userImageImageView.layer.cornerRadius = self.bounds.height / 2
            self.userImageImageView.image = UIImage(named: "logo.small.background.black")
            self.userInitialsLabel.isHidden = true
            self.userImageImageView.isHidden = false
        }
    }

}
