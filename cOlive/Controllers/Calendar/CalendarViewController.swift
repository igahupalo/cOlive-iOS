//
//  CalendarViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 05/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet var upSwipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet var downGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!

    var user: User?
    var flat: Flat?

    private var events: Events
    private var selectedDate: Date?
    private var selectedDateEvents: [Event]?

    required init?(coder: NSCoder) {
        self.events = Events()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
        eventsTableView.tableFooterView = UIView()
        
        if let flat = flat {
            self.events.fetch(flat: flat) {
                self.selectedDateEvents = self.events.eventsArray.filter( { $0.isHappeningOn(dayOf: Date()) } )
                self.eventsTableView.reloadData()
                self.calendar.reloadData()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            self.events.detachListeners()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.calendarToEditEventSegue:
            let addEventViewController = segue.destination as! EditEventViewController
            addEventViewController.user = self.user
            addEventViewController.flatId = self.flat?.documentId
        case Constants.Storyboard.calendarToEventSegue:
            let eventViewController = segue.destination as! EventViewController
            eventViewController.user = self.user
            eventViewController.event = (sender as! EventTableViewCell).event
            eventViewController.author = (sender as! EventTableViewCell).author
        default:
            break
        }
    }

    @IBAction func upSwipe(_ sender: Any) {
        self.calendar.setScope(.week, animated: true)
        self.eventsTableView.isScrollEnabled = true
    }

    @IBAction func downSwipe(_ sender: Any) {
        self.calendar.setScope(.month, animated: true)
        if self.selectedDateEvents?.count ?? 0 > 0 { self.eventsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true) }
        self.eventsTableView.isScrollEnabled = false

    }

    @IBAction func rightSwipe(_ sender: Any) {
    }

    @IBAction func leftSwipe(_ sender: Any) {
    }

    private func setupCalendar() {
        calendar.appearance.titleFont = UIFont(name: "Now", size: 14)
        calendar.appearance.headerTitleFont = UIFont(name: "Now-Bold", size: 16)
        calendar.appearance.weekdayFont = UIFont(name: "Now", size: 14)
        calendar.appearance.subtitleFont = UIFont(name: "Now", size: 12)
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let events = self.events.eventsArray.filter( { $0.isHappeningOn(dayOf: date) } )
        return events.count
    }

    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) { self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.selectedDate = date
        self.selectedDateEvents = self.events.eventsArray.filter( { $0.isHappeningOn(dayOf: date) } )
        self.eventsTableView.reloadData()

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM yyyy"
        self.selectedDateLabel.text = formatter.string(from: date)
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedDateEvents?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.eventTableViewCell) as! EventTableViewCell
        let event = self.selectedDateEvents?[indexPath.row]
        cell.event = event
        cell.author = self.flat?.members?.membersArray.first(where: { $0.userId == event?.authorId } )
        cell.setContent()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? EventTableViewCell else { return }
        cell.isSelected = false
        self.performSegue(withIdentifier: Constants.Storyboard.calendarToEventSegue, sender: cell)
    }
}
