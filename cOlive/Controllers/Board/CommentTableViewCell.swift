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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupContent() {
        self.authorImageView.user = self.author?.user
        self.contentLabel.text = self.comment?.content
        let formatter = RelativeDateTimeFormatter()
        self.infoLabel.text = "\(self.author?.user?.displayName ?? "Author") ⋅ \(formatter.string(for: self.comment?.date) ?? "")"
    }

}
