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

        if let flat = flat {
            self.events.fetch(flat: flat) {
                print(self.events.eventsArray)
                self.calendar.reloadData()
            }
        }

        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.events.detachListeners()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.calendarToAddEventSegue:
            let addEventViewController = segue.destination as! AddEventViewController
            addEventViewController.user = self.user
            addEventViewController.flat = self.flat
        default:
            break
        }
    }


    func setupCalendar() {
        calendar.appearance.titleFont = UIFont(name: "Now", size: 16)
        calendar.appearance.headerTitleFont = UIFont(name: "Now-Bold", size: 16)
        calendar.appearance.weekdayFont = UIFont(name: "Now", size: 12)
        calendar.appearance.subtitleFont = UIFont(name: "Now", size: 12)

//        calendar.scope = .week

    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let events = self.events.eventsArray.filter( { $0.isHappeningOn(dayOf: date) } )
        return events.count
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.selectedDate = date
        self.selectedDateEvents = self.events.eventsArray.filter( { $0.isHappeningOn(dayOf: date) } )
        self.eventsTableView.reloadData()

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM yyyy"
        self.selectedDateLabel.text = formatter.string(from: date)
    }
//
//    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
//
//    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedDateEvents?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.eventTableViewCell) as! EventTableViewCell
        let event = self.selectedDateEvents?[indexPath.row]
        cell.event = event
        cell.setContent()

        return cell
    }
}


