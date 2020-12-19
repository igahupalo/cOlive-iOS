//
//  ShareCode.swift
//  cOlive
//
//  Created by Iga Hupalo on 18/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore

class InvitationCode {
    let db: Firestore = Firestore.firestore()

    var flatId: String?
    var date: Date?
    var code: String?
    var expirationDate: Date?

    init(flatId: String, code: String, date: Date) {
        self.flatId = flatId
        self.code = code
        self.date = date
        var validPeriod = DateComponents()
        validPeriod.day = 2
        self.expirationDate = Calendar.current.date(byAdding: validPeriod, to: date)
    }

    convenience init(flatId: String) {

        self.init(flatId: flatId, code: "", date: Date())
    }

    convenience init(code: String) {
        self.init(flatId: "", code: code, date: Date())
    }

    convenience init(dictionary: [String: Any]) {
        let flatId = dictionary["flat_id"] as! String? ?? ""
        let code = dictionary["code"] as! String? ?? ""
        let dateTimeInterval = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: dateTimeInterval)

        self.init(flatId: flatId, code: code, date: date)
    }

    var dictionary: [String: Any] {
        let dateTimeInterval = self.date?.timeIntervalSince1970
        let expirationDateTimeInterval = self.expirationDate?.timeIntervalSince1970

        return ["flat_id": self.flatId ?? "", "code": self.code ?? "", "date": dateTimeInterval ?? Date(), "expiration_date": expirationDateTimeInterval ?? Date()]
    }

    func setData(dictionary: [String: Any?]) {
        self.flatId = dictionary["flat_id"] as! String? ?? ""
        self.code = dictionary["code"] as! String? ?? ""
        let dateTimeInterval = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        self.date = Date(timeIntervalSince1970: dateTimeInterval)
        let expirationDateTimeInterval = dictionary["expiration_date"] as! TimeInterval? ?? TimeInterval()
        self.expirationDate = Date(timeIntervalSince1970: expirationDateTimeInterval)
    }

    func generate(completion: @escaping () -> ()) {
        let invitationCodes = InvitationCodes()
        invitationCodes.fetch(validOn: Date()) {
            repeat {
                self.code = self.random(digits: 5)
            } while invitationCodes.isTaken(code: self.code!)

            self.save { (_) in
                completion()
            }
        }
    }

    func fetchValid(completion: @escaping (Bool) -> ()) {
        let currentDateTimeInterval = Date().timeIntervalSince1970

        guard let code = self.code else {
            completion(false)
            return
        }

        db.collection("invitation_codes").whereField("code", isEqualTo: code).whereField("expiration_date", isGreaterThan: currentDateTimeInterval).getDocuments { documentSnapshots, error in
            guard error == nil else {
                print("🔴 ERROR: Fetching snapshots: \(error!)")
                completion(false)
                return
            }
            if documentSnapshots?.documents.count == 0 {
                completion(false)
                return
            }
            let document = documentSnapshots?.documents[0]
            if let data = document?.data() {
                self.setData(dictionary: data)

                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func save(completion: @escaping (Bool) -> ()) {
        let ref = db.collection("invitation_codes").document()
        ref.setData(self.dictionary) { error in
            if let error = error {
                print("🔴 DATABASE ERROR: Creating share code \(error.localizedDescription)")
                completion(false)
            }
        }
        print("🟢 DATABASE: Created share code")
        completion(true)
    }

    private func random(digits: Int) -> String {
        var number = String()
        for _ in 1...digits {
           number += "\(Int.random(in: 0...9))"
        }
        return number
    }
}
