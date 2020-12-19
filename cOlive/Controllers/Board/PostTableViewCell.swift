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

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupContainerShadow()
    }

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

    private func setupContainerShadow() {

        let shadowLayer = self.mainView.layer
        shadowLayer.shadowColor = (UIColor(named: "Black 30%") ?? UIColor.black).cgColor
        shadowLayer.shadowOpacity = 0.3
        shadowLayer.shadowRadius = 3
        shadowLayer.shadowOffset = CGSize(width: 3, height: 3)
        self.mainView.layer.masksToBounds = false
    }

    func setupContent() {
        let formatter = RelativeDateTimeFormatter()
        let postInfo = "\(self.author?.user?.displayName ?? "Author") ⋅ \(formatter.string(for: self.post?.date ?? Date()) ?? "")"
        self.postInfoLabel.text = postInfo
        self.userImageView.user = self.author?.user
        self.postTitleLabel.text = self.post?.title
        self.postContentLabel.text = self.post?.content
        self.postTitleLabel.text = self.post?.title
        self.postTitleLabel.text = self.post?.title
        if let image = self.post?.image {
            self.postImageImageView.isHidden = false
            self.postImageImageView.image = image

        } else {
            self.postImageImageView.isHidden = true
        }
    }
}
