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
            self.editImageView.isHidden = !hasEditIcon
        }
    }

    weak var user: User? {
        didSet {
            setContent()
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
        view.frame = bounds
        addSubview(view)
    }

    func setContent() {
        if let user = user {
            if let image = user.image {
                setUserImage(image)
            } else {
                setInitials(user.displayName)
            }
        } else {
            setDefaultImage()
        }
    }
}

private extension ProfileImageView {
    // Sets given image as profile image.
    func setUserImage(_ image: UIImage) {
        userImageImageView.layer.cornerRadius = self.bounds.height / 2
        userImageImageView.image = image
        userInitialsLabel.isHidden = true
        userImageImageView.isHidden = false
    }

    // Sets first letter of users' display name as profile image.
    func setInitials(_ displayName: String) {
        var initials: String
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .abbreviated

        if let components = formatter.personNameComponents(from: displayName) {
            initials = formatter.string(from: components)
            userInitialsLabel.layer.cornerRadius = self.bounds.height / 2
            userInitialsLabel.text = initials
            userImageImageView.isHidden = true
            userInitialsLabel.isHidden = false
        }
    }

    // Sets app logo as profile image.
    func setDefaultImage() {
        userImageImageView.layer.cornerRadius = self.bounds.height / 2
        userImageImageView.image = UIImage(named: "logo.small.background.black")
        userInitialsLabel.isHidden = true
        userImageImageView.isHidden = false
    }
}
