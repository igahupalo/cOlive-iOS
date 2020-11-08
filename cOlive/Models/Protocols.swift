//
//  Protocols.swift
//  cOlive
//
//  Created by Iga Hupalo on 03/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol UserProtocol {
    var uid: String { get }
    var username: String { get set }
    var email: String { get set }
    var firstName: String? { get set }
    var lastName: String? { get set }
    var membershipId: String? { get set }
    var membership: Membership? { get set }
//    var imageUrl: String?
    var dictionary: [String: Any] { get }

    // MARK: Firebase functions.

    func save(completion: @escaping (Bool) -> ())
    func fetchMembership(completion: @escaping () -> ())
}

protocol MembershipProtocol {
    var flatId: String { get set }
    var isActive: Bool { get set }
    var lastUsed: Date { get set }
    var type: Membership.MembershipType { get set }
    var flat: Flat { get set }
    var dictionary: [String: Any] { get }

    func setData(dictionary: [String: Any])

    // MARK: Firebase functions.

    func fetch(user: User, completion: @escaping () -> ())
    func save(user: User, completion: @escaping (Bool) -> ())
    func fetchFlat(completion: @escaping () -> ())
}

protocol MembershipsProtocol {
    var membershipsArray: [Membership] { get }

    // MARK: Firebase functions.

    func fetch(user: User, completion: @escaping () -> ())
    func save(user: User, completion: @escaping (Bool) -> ())
    func fetchFlats(completion: @escaping () -> ())
}

protocol FlatProtocol {
    var name: String { get set }
    var ownerId: String { get set }
    var isActive: Bool { get set }
    var imageUrl: String? { get set }
    var image: UIImage? { get set }
    var dictionary: [String: Any] { get }

    // MARK: Firebase functions.

    func fetch(completion: @escaping () -> ())
    func save(completion: @escaping (Bool) -> ())
    func saveImage(completion: @escaping (Bool) -> ())
    func create(owner user: User, completion: @escaping (Bool) -> ())
    func delete()
}
