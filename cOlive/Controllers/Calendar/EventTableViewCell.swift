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
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var userImageView: ProfileImageView!

    var event: Event?
    var author: Member?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setContent() {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        let startDate = self.event?.startDate ?? Date()
        let endDate = self.event?.endDate ?? Date()
        self.eventDateLabel.text = formatter.string(from: startDate, to: endDate)
        eventTitleLabel.text = event?.title
        userImageView.user = author?.user
    }
}
