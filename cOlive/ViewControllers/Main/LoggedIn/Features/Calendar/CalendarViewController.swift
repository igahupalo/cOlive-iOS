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
    @IBOutlet weak var topCardView: UIView!

    var user: User?
    var flat: Flat?

    private var events = Events()
    private var selectedDate: Date?
    private var selectedDateEvents: [Event]?
    private var formatter: DateFormatter?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchEvents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = UIColor(named: Constants.Colors.tintColorName)
        if isMovingFromParent {
            events.detachListeners()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.calendarToEditEventSegue:
            let addEventViewController = segue.destination as! EditEventViewController
            addEventViewController.user = user
            addEventViewController.flatId = flat?.documentId
        case Constants.Storyboard.calendarToEventSegue:
            let eventViewController = segue.destination as! EventViewController
            eventViewController.user = user
            eventViewController.event = (sender as! EventTableViewCell).event
            eventViewController.author = (sender as! EventTableViewCell).author
        default:
            break
        }
    }

    // MARK: Event handlers

    @IBAction func upSwipe(_ sender: Any) {
        calendar.setScope(.week, animated: true)
        eventsTableView.isScrollEnabled = true
    }

    @IBAction func downSwipe(_ sender: Any) {
        calendar.setScope(.month, animated: true)
        if selectedDateEvents?.count ?? 0 > 0 {
            eventsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
        }
        eventsTableView.isScrollEnabled = false

    }
}

// MARK: FSCalendarDelegate, FSCalendarDataSource

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

        self.selectedDateLabel.text = formatter?.string(from: date)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

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

// MARK: Private

private extension CalendarViewController {
    func setupView() {
        formatter = DateFormatter()
        formatter?.dateFormat = "EEEE, d MMM yyyy"
        topCardView.layer.cornerRadius = 24
        topCardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        eventsTableView.tableFooterView = UIView()
        selectedDateLabel.text = formatter?.string(from: Date())

        setupCalendar()
    }

    func setupCalendar() {
        calendar.appearance.titleFont = UIFont(name: "Now", size: 14)
        calendar.appearance.headerTitleFont = UIFont(name: "Now-Bold", size: 16)
        calendar.appearance.weekdayFont = UIFont(name: "Now", size: 14)
        calendar.appearance.subtitleFont = UIFont(name: "Now", size: 12)
    }

    func fetchEvents() {
        if let flat = flat {
            events.fetch(flat: flat) { [weak self] in
                if let self = self {
                    self.selectedDateEvents = self.events.eventsArray.filter( { $0.isHappeningOn(dayOf: Date()) } )
                    self.eventsTableView.reloadData()
                    self.calendar.reloadData()
                }
            }
        }
    }
}
