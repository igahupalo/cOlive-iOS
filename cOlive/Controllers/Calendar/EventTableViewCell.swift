//
//  EventTableViewCell.swift
//  cOlive
//
//  Created by Iga Hupalo on 13/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventTitleLabel: UILabel!

    var event: Event?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setContent() {
        eventTitleLabel.text = event?.title
    }

}
