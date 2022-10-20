//
//  CommentTableViewCell.swift
//  cOlive
//
//  Created by Iga Hupalo on 26/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var authorImageView: ProfileImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    weak var comment: Comment?
    weak var author: Member?

    func setupContent() {
        authorImageView.user = author?.user
        contentLabel.text = comment?.content
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Constants.Locales.defaultLocale
        infoLabel.text = "\(author?.user?.displayName ?? "Author") ⋅ \(formatter.string(for: comment?.date) ?? "")"
    }

}
