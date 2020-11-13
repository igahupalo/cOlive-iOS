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
        if let user = user {
            guard let _ = user.membershipId else {
                setupNoMembershipLayout()
                return
            }
            self.memberships.fetch(user: user) {
                self.memberships.fetchFlats {
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
        memberships.detachListeners()
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

    private func setupNoMembershipLayout() {
        self.backgroundImageView.isHidden = false
        self.flatList.isHidden = true
        self.buttonStackView.axis = .vertical
        for constraint in self.view.constraints {
            if constraint.identifier == "myConstraint" {
               constraint.constant = 50
            }
        }
        myView.layoutIfNeeded()
    }
}

extension FlatsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberships.membershipsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.flatTableViewCell) as! FlatTableViewCell
        let membership = memberships.membershipsArray[indexPath.row]
        cell.membership = membership
        cell.setContent()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let membershipId = memberships.membershipsArray[indexPath.row].documentId {
            self.user?.setMembership(membershipId: membershipId) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
