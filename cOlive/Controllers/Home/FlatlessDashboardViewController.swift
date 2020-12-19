//
//  NoFlatViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 16/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class FlatlessDashboardViewController: UIViewController {

    @IBOutlet weak var placeholder: UIView!
    @IBOutlet weak var membershipsTableView: UITableView!
    @IBOutlet weak var membershipsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var membershipsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var membershipsView: UIStackView!

    weak var activityIndicator: UIActivityIndicatorView?
    weak var user: User?
    var memberships: Memberships?

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.setupMembershipsTableView()
//        self.activityIndicator?.stopAnimating()
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupMembershipsTableView()
        self.activityIndicator?.stopAnimating()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.flatlessDashboardToCreateFlatSegue:
            let createFlatViewController = segue.destination as! CreateFlatViewController
            self.memberships?.detachListeners()
            createFlatViewController.user = self.user
        case Constants.Storyboard.flatlessDashboardToCheckInSegue:
            let checkInViewController = segue.destination as! CheckInViewController
            self.memberships?.detachListeners()
            checkInViewController.user = self.user
        default:
            break
        }
    }

    func setupMembershipsTableView() {
        self.memberships = Memberships()
        if let user = self.user {
            self.memberships?.fetch(user: user) {
                if (self.memberships?.membershipsArray.count ?? 0) > 0 {
                    self.membershipsHeightConstraint?.constant = CGFloat((self.memberships?.membershipsArray.count ?? .zero) * 50)
                    self.membershipsTableView.reloadData()
                    self.view.layoutIfNeeded()
                    self.membershipsActivityIndicator?.stopAnimating()
                    self.placeholder.isHidden = true
                    self.membershipsView.isHidden = false
                } else {
                    self.membershipsActivityIndicator?.stopAnimating()
                    self.placeholder.isHidden = false
                    self.membershipsView.isHidden = true
                }
            }
        }
    }
}

extension FlatlessDashboardViewController: UITableViewDelegate, UITableViewDataSource, MembershipTableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberships?.membershipsArray.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.flatTableViewCell) as! MembershipTableViewCell
        let membership = self.memberships?.membershipsArray[indexPath.row]
        cell.membershipTableViewDelegate = self
        cell.membership = membership
        cell.user = self.user
        cell.setContent()
        return cell
    }

    func enterButtonTapped(cell: MembershipTableViewCell?) {
        if let membershipId = cell?.membership?.documentId {
            self.user?.setMembership(membershipId: membershipId) { [weak self] in
                self?.memberships?.detachListeners()
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
