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

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMemberships()
        activityIndicator?.stopAnimating()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.flatlessDashboardToCreateFlatSegue:
            let createFlatViewController = segue.destination as! CreateFlatViewController
            memberships?.detachListeners()
            createFlatViewController.user = user
        case Constants.Storyboard.flatlessDashboardToCheckInSegue:
            let checkInViewController = segue.destination as! CheckInViewController
            memberships?.detachListeners()
            checkInViewController.user = user
        default:
            break
        }
    }
}

// MARK: - Flats table delegate, flats table data source

extension FlatlessDashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberships?.membershipsArray.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.flatTableViewCell) as! MembershipTableViewCell
        let membership = memberships?.membershipsArray[indexPath.row]
        cell.membershipTableViewDelegate = self
        cell.membership = membership
        cell.user = user
        cell.setContent()
        return cell
    }
}

extension FlatlessDashboardViewController: MembershipTableViewDelegate {
    func enterButtonTapped(cell: MembershipTableViewCell?) {
        if let membershipId = cell?.membership?.documentId {
            user?.setMembership(membershipId: membershipId) { [weak self] in
                self?.memberships?.detachListeners()
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: Private

private extension FlatlessDashboardViewController {
    func fetchMemberships() {
        memberships = Memberships()
        if let user = user {
            memberships?.fetch(user: user) { [weak self] in
                guard let self = self else { return }
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
