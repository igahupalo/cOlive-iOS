//
//  TableViewCell.swift
//  cOlive
//
//  Created by Iga Hupalo on 19/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class FlatTableViewCell: UITableViewCell {

    @IBOutlet weak var flatNameLabel: UILabel!
    @IBOutlet weak var flatImageImageView: UIImageView!

    var membership: Membership?
    var flat: Flat?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setContent() {
        guard let membership = membership else {
            return
        }
        let flat = Flat(documentId: membership.flatId)
        flat.fetchData {
            self.flatNameLabel.text = flat.name
            self.flatImageImageView.image = flat.image
        }
    }
}
