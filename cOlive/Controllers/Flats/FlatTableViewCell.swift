//
//  TableViewCell.swift
//  cOlive
//
//  Created by Iga Hupalo on 19/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class FlatTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageImageView: UIImageView!

    var membership: Membership?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = ""
        imageImageView.image = UIImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setContent() {
        guard let membership = membership else {
            return
        }
        let flat = membership.flat
        self.nameLabel.text = flat.name
        self.imageImageView.image = flat.image
    }
}
