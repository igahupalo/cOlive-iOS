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

    func setContent() {
        if event?.isAllDay ?? false {
            eventTitleLabel.text = "All-day"
        } else {
            let startDate = event?.startDate ?? Date()
            let endDate = event?.endDate ?? Date()
            let formatter = DateIntervalFormatter()
            formatter.locale = Constants.Locales.defaultLocale
            formatter.dateStyle = .medium
            eventDateLabel.text = formatter.string(from: startDate, to: endDate)
        }
        eventTitleLabel.text = event?.title
        userImageView.user = author?.user
    }
}
