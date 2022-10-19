//
//  Events.swift
//  cOlive
//
//  Created by Iga Hupalo on 11/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Events {
    let db: Firestore = Firestore.firestore()
    var eventsArray: [Event]
    var listener: ListenerRegistration?

    init() {
        self.eventsArray = []
    }

    deinit {
        print("🟦 events deinit")
    }

    // MARK: Database functions

    func fetch(flat: Flat, completion: @escaping () -> ()) {
        guard let flatId = flat.documentId else {
            print("🔴 ERROR: Fetching events")
            return completion()
        }

        self.listener = db.collection("flats").document(flatId).collection("events").whereField("is_active", isEqualTo: true).addSnapshotListener { documentSnapshots, error in
            guard error == nil else {
                completion()
                return
            }
            guard let snapshots = documentSnapshots else {
                print("🔴 ERROR: Fetching snapshots: \(error!)")
                return
            }
            snapshots.documentChanges.forEach { snapshot in
                let type = snapshot.type
                let document = snapshot.document
                let documentId = document.documentID
                let data = document.data()

                if (type == .added) {
                    let event = Event(dictionary: document.data())
                    event.documentId = document.documentID
                    self.eventsArray.append(event)
                    print("🟢 Added event \(String(describing: event.documentId))")
                }
                if (type == .modified) {
                    if let eventIndex = self.eventsArray.firstIndex(where: { $0.documentId == documentId }) {
                        self.eventsArray[eventIndex].setData(dictionary: data)
                        print("🟢 Updated event \(String(describing: documentId))")
                    }
                }
                if (type == .removed) {
                    if let eventIndex = self.eventsArray.firstIndex(where: { $0.documentId == documentId }) {
                        self.eventsArray.remove(at: eventIndex)
                        print("🟢 Deleted event \(String(describing: documentId))")
                    }
                }
            }

            self.eventsArray.sort { $0.startDate > $1.startDate }

            completion()
        }
    }

    func detachListeners() {
        if let listener = self.listener {
            print("🔷 Listener detached - events")
            listener.remove()
        }
    }
}
