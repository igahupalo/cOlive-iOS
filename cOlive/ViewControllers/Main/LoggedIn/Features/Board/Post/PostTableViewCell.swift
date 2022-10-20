//
//  PostTableViewCell.swift
//  cOlive
//
//  Created by Iga Hupalo on 23/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var userImageView: ProfileImageView!
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var commentNumberLabel: UILabel!
    @IBOutlet weak var postImageImageView: UIImageView!
    @IBOutlet weak var mainView: UIView!

    weak var post: Post?
    weak var author: Member?
    var commentNumber = 0

    private var selectedShadowOffsetSize = CGSize(width: 0, height: 0)
    private var deselectedShadowOffsetSize = CGSize(width: 3, height: 3)

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupContainerShadow()
    }

    // MARK: Handlers

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        DispatchQueue.main.async {
            self.mainView.layer.shadowOffset = self.deselectedShadowOffsetSize
            UIView.animate(withDuration: 0.2, animations: {
                self.mainView.layer.shadowOffset = self.selectedShadowOffsetSize
            })

        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        DispatchQueue.main.async {
            self.mainView.layer.shadowOffset = self.selectedShadowOffsetSize
            UIView.animate(withDuration: 0.2, animations: {
                self.mainView.layer.shadowOffset = self.deselectedShadowOffsetSize
            })
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.mainView.layer.shadowOffset = self.selectedShadowOffsetSize
            UIView.animate(withDuration: 0.2, animations: {
                self.mainView.layer.shadowOffset = self.deselectedShadowOffsetSize
            })
        }
    }

    func setupContent() {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Constants.Locales.defaultLocale
        let postInfo = "\(author?.user?.displayName ?? "Author") ⋅ \(formatter.string(for: post?.date ?? Date()) ?? "")"
        postInfoLabel.text = postInfo
        postTitleLabel.text = post?.title
        postTitleLabel.text = post?.title
        userImageView.user = author?.user

        if let content = post?.content {
            postContentLabel.isHidden = false
            postContentLabel.text = content
        }

        if let image = post?.image {
            postImageImageView.isHidden = false
            postImageImageView.image = image

        } else {
            postImageImageView.isHidden = true
        }
    }
}

// MARK: Private

private extension PostTableViewCell {
    func setupContainerShadow() {
        let shadowLayer = mainView.layer
        shadowLayer.shadowColor = (UIColor(named: "black-opaque") ?? UIColor.black).cgColor
        shadowLayer.shadowOpacity = 0.3
        shadowLayer.shadowRadius = 3
        shadowLayer.shadowOffset = CGSize(width: 3, height: 3)
        mainView.layer.masksToBounds = false
    }

}
