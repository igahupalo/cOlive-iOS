//
//  EventViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 20/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var authorImageView: ProfileImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!

    weak var author: Member?
    weak var event: Event?
    weak var user: User?

    override func viewWillAppear(_ animated: Bool) {
        self.setupAuthorInfo()
        self.setupEventInfo()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.eventToEditEventSegue:
            let editEventViewController = segue.destination as! EditEventViewController
            editEventViewController.user = user
            editEventViewController.flatId = user?.membershipId
            editEventViewController.event = event
        default:
            break
        }
    }
}

private extension EventViewController {
    func setupAuthorInfo() {
        authorImageView.user = author?.user
        authorNameLabel.text = author?.user?.displayName
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Constants.Locales.defaultLocale
        createdDateLabel.text = formatter.localizedString(for: event?.date ?? Date(), relativeTo: Date())

        if user?.documentId != event?.authorId {
            editBarButtonItem.isEnabled = false
            editBarButtonItem.image = UIImage()
        }
    }

    func setupEventInfo() {
        titleLabel.text = event?.title
        descriptionLabel.text = event?.description ?? ""
        let formatter = DateIntervalFormatter()
        formatter.locale = Constants.Locales.defaultLocale
        formatter.dateStyle = .medium
        let startDate = event?.startDate ?? Date()
        let endDate = event?.endDate ?? Date()
        dateLabel.text = formatter.string(from: startDate, to: endDate)
    }
}
