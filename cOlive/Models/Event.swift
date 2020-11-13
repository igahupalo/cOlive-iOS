//
//  Event.swift
//  cOlive
//
//  Created by Iga Hupalo on 11/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Event {
    let db: Firestore = Firestore.firestore()
    var documentId: String?
    var listener: ListenerRegistration?
    
    var title: String
    var description: String
    var isAllDay: Bool
    var startDate: Date
    var endDate: Date
    var author: User?
    var authorId: String
    var isActive: Bool

    var dictionary: [String: Any] {
        let startTimeInterval = startDate.timeIntervalSince1970
        let endTimeInterval = endDate.timeIntervalSince1970
        return ["title": title, "description": description, "is_all_day": isAllDay, "start_date": startTimeInterval, "end_date": endTimeInterval, "author_id": authorId, "is_active": isActive]
    }

    deinit {
        print("🟦 event deinit")
    }

    init(title: String, description: String, isAllDay: Bool, startDate: Date, endDate: Date, authorId: String, isActive: Bool) {
        self.title = title
        self.description = description
        self.isAllDay = isAllDay
        self.startDate = startDate
        self.endDate = endDate
        self.authorId = authorId
        self.isActive = isActive

        if isAllDay { self.roundUpDateRange() }
    }

    convenience init(documentId: String) {
        self.init(title: "", description: "", isAllDay: false, startDate: Date(), endDate: Date(), authorId: "", isActive: true)
        self.documentId = documentId
    }

    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let description = dictionary["description"] as! String? ?? ""
        let isAllDay = dictionary["is_all_days"] as! Bool? ?? false
        let startTimeIntervalDate = dictionary["start_date"] as! TimeInterval? ?? TimeInterval()
        let startDate = Date(timeIntervalSince1970: startTimeIntervalDate)
        let endTimeIntervalDate = dictionary["end_date"] as! TimeInterval? ?? TimeInterval()
        let endDate = Date(timeIntervalSince1970: endTimeIntervalDate)
        let authorId = dictionary["author_id"] as! String? ?? ""
        let isActive = dictionary["is_active"] as! Bool? ?? true

        self.init(title: title, description: description, isAllDay: isAllDay, startDate: startDate, endDate: endDate, authorId: authorId, isActive: isActive)
    }

    func setData(dictionary: [String: Any]) {
        self.title = dictionary["title"] as! String? ?? ""
        self.description = dictionary["description"] as! String? ?? ""
        self.isAllDay = dictionary["is_all_days"] as! Bool? ?? true
        let startTimeIntervalDate = dictionary["start_date"] as! TimeInterval? ?? TimeInterval()
        self.startDate = Date(timeIntervalSince1970: startTimeIntervalDate)
        let endTimeIntervalDate = dictionary["end_date"] as! TimeInterval? ?? TimeInterval()
        self.endDate = Date(timeIntervalSince1970: endTimeIntervalDate)
        self.authorId = dictionary["author_id"] as! String? ?? ""
        self.isActive = dictionary["is_active"] as! Bool? ?? true
    }

    func roundUpDateRange() {
        var startDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: startDate)
        var endDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: endDate)

        startDateComponents.hour = 1
        startDateComponents.minute = 0
        endDateComponents.hour = 23
        endDateComponents.minute = 59
        endDateComponents.second = 59

        startDate = Calendar.current.date(from: startDateComponents) ?? Date()
        endDate = Calendar.current.date(from: endDateComponents) ?? Date()
    }

    func isHappeningOn(dayOf date: Date) -> Bool {
        let startDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: startDate)
        let endDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: endDate)
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)

        let startRoundedUp =  Calendar.current.date(from: startDateComponents) ?? Date()
        let endRoundedUp =  Calendar.current.date(from: endDateComponents) ?? Date()
        let dateRoundedUp =  Calendar.current.date(from: dateComponents) ?? Date()

        return startRoundedUp <= dateRoundedUp && dateRoundedUp <= endRoundedUp
    }

    // MARK: Database functions

    func save(flat: Flat, completion: @escaping (Bool) -> ()) {
        guard let flatId = flat.documentId else {
            print("🔴 DATABASE ERROR: updating event \(String(describing: documentId))")
            return completion(false)
        }
        if let documentId = documentId {
            let ref = db.collection("flats").document(flatId).collection("events").document(documentId)
            ref.setData(self.dictionary) { error in
                if let error = error {
                    print("🔴 ERROR: Updating event \(documentId) \(error.localizedDescription)")
                    completion(false)
                }
                print("🟢 DATABASE: Updated event \(String(describing: documentId))")
                completion(true)
            }
        } else {
            let ref = db.collection("flats").document(flatId).collection("events").document()
            ref.setData(self.dictionary) { error in
                if let error = error {
                    print("🔴 DATABASE ERROR: Creating event \(error.localizedDescription)")
                    completion(false)
                }
                self.documentId = ref.documentID
                print("🟢 DATABASE: Created event \(String(describing: self.documentId))")
                completion(true)
            }
        }
    }
}
