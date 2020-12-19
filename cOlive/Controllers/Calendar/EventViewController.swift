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

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func viewWillAppear(_ animated: Bool) {
        self.setupAuthorInfo()
        self.setupEventInfo()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.eventToEditEventSegue:
            let editEventViewController = segue.destination as! EditEventViewController
            editEventViewController.user = self.user
            editEventViewController.flatId = self.user?.membershipId
            editEventViewController.event = self.event
        default:
            break
        }
    }

    private func setupAuthorInfo() {
        self.authorImageView.user = self.author?.user
        self.authorNameLabel.text = self.self.author?.user?.displayName
        let formatter = RelativeDateTimeFormatter()
        self.createdDateLabel.text = formatter.localizedString(for: self.event?.date ?? Date(), relativeTo: Date())

        if user?.documentId != event?.authorId {
            self.editBarButtonItem.isEnabled = false
            editBarButtonItem.image = UIImage()
        }
    }

    private func setupEventInfo() {
        self.titleLabel.text = self.event?.title
        self.descriptionLabel.text = self.event?.description ?? "No event description"
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        let startDate = self.event?.startDate ?? Date()
        let endDate = self.event?.endDate ?? Date()
        self.dateLabel.text = formatter.string(from: startDate, to: endDate)
    }

    @IBAction func editButtonTapped(_ sender: Any) {
        
    }
}
