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

    var memberships: Memberships?
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
        if let currentUser = user {
            self.memberships?.fetch(user: currentUser) {
                self.memberships?.fetchFlats {
                    self.flatList.reloadData()
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.flatList.reloadData()

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if let memberships = self.memberships {
            memberships.detachListeners()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.flatsToAddFlatSegue:
            let addFlatViewController = segue.destination as! AddFlatViewController
            addFlatViewController.currentUser = self.user
            addFlatViewController.memberships = self.memberships
        default:
            break
        }
    }
}

extension FlatsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberships?.membershipsArray.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlatTableViewCell") as! FlatTableViewCell
        if let membership = memberships?.membershipsArray[indexPath.row] {
            cell.membership = membership
            cell.setContent()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let membership = memberships?.membershipsArray[indexPath.row] {
            if let membershipId = membership.documentId {
                self.user?.setMembership(membershipId: membershipId) { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
