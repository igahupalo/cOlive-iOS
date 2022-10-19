//
//  ShareCodes.swift
//  cOlive
//
//  Created by Iga Hupalo on 18/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore

class InvitationCodes {
    let db: Firestore = Firestore.firestore()

    var invitationCodesArray: [InvitationCode]

    init() {
        self.invitationCodesArray = []
    }

    func isTaken(code: String) -> Bool {
        return invitationCodesArray.contains(where: { $0.code == code } )
    }

    func fetch(validOn date: Date, completion: @escaping () -> ()) {
        let dateTimeInterval = date.timeIntervalSince1970
        db.collection("shared_codes").whereField("expiration_date", isGreaterThan: dateTimeInterval).getDocuments { documentSnapshots, error in
            guard error == nil else {
                print("🔴 ERROR: Fetching snapshots: \(error!)")
                completion()
                return
            }

            documentSnapshots?.documents.forEach { document in
                let data = document.data()
                let invitationCode = InvitationCode(dictionary: data)
                self.invitationCodesArray.append(invitationCode)
            }

            completion()
        }
    }

}
