//
//  FlatsViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 18/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class FlatsViewController: UIViewController {

    @IBOutlet weak var flatList: UITableView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var headerLabel: UILabel!

    var memberships: Memberships
    var user: User?

    deinit {
        print("🟦 flatsVC deinit")
    }

    required init?(coder: NSCoder) {
        self.memberships = Memberships()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let user = user {
            self.memberships.fetch(user: user) {
                self.flatList.reloadData()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        memberships.detachListeners()
    }


}

extension FlatsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberships.membershipsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.flatTableViewCell) as! MembershipTableViewCell
        let membership = memberships.membershipsArray[indexPath.row]
        cell.membership = membership
        cell.setContent()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let membershipId = memberships.membershipsArray[indexPath.row].flatId
        self.user?.setMembership(membershipId: membershipId) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
