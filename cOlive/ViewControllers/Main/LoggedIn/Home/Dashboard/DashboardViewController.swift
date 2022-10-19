//
//  DashboardViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 16/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    @IBOutlet weak var featuresCollectionView: UICollectionView!
    @IBOutlet weak var membersTableView: UITableView!
    @IBOutlet weak var flatNameLabel: UILabel!
    @IBOutlet weak var membersTableViewHeightConstraint: NSLayoutConstraint!

    weak var activityIndicator: UIActivityIndicatorView?

    weak var user: User?
    weak var flat: Flat?

    private var featureImages: [UIImage] = []
    private var featureNames: [String] = []
    private var featureSegueIdentifiers: [String] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        flat = user?.membership?.flat
        setupContent()
        fetchMembers()

    }

    override func viewWillAppear(_ animated: Bool) {
        setupContent()
        membersTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.dashboardToCalendarSegue:
            let calendarViewController = segue.destination as! CalendarViewController
            calendarViewController.user = user
            calendarViewController.flat = flat
        case Constants.Storyboard.dashboardToBoardSegue:
            let boardViewController = segue.destination as! BoardViewController
            boardViewController.user = user
            boardViewController.flat = flat
        case Constants.Storyboard.dashboardToRemoveUserSegue:
            let removeUserViewController = segue.destination as! RemoveUserViewController
            removeUserViewController.member = (sender as! MemberTableViewCell).member
            removeUserViewController.flat = flat
        case Constants.Storyboard.dashboardToLeaveFlatSegue:
            let leaveFlatViewController = segue.destination as! LeaveFlatViewController
            leaveFlatViewController.member = (sender as! CurrentMemberTableViewCell).member
            leaveFlatViewController.flat = flat
        case Constants.Storyboard.dashboardToChangeFlatNameSegue:
            let changeFlatNameViewController = segue.destination as! ChangeFlatNameViewController
            changeFlatNameViewController.flat = flat
            changeFlatNameViewController.changeFlatNameDelegate = self
        case Constants.Storyboard.dashboardToInviteSegue:
            let inviteViewController = segue.destination as! InviteViewController
            inviteViewController.flat = flat
        default:
            break
        }
    }

    func reload() {
        membersTableView.reloadData()
    }
}

// MARK: - Features collection delegate, Features collection data source

extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featureNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = featuresCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifiers.featureCollectionViewCell, for: indexPath) as! FeatureCollectionViewCell

        cell.imageView.image = featureImages[indexPath.row]
        cell.nameLabel.text = featureNames[indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: featureSegueIdentifiers[indexPath.row], sender: self)
    }

}

// MARK: - Members table delegate, Members table data source

extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flat?.members?.membersArray.filter( { $0.isActive } ).count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let member = flat?.members?.membersArray.filter( { $0.isActive } )[indexPath.row]
        if member?.userId == user?.documentId {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.currentMemberTableViewCell, for: indexPath) as! CurrentMemberTableViewCell
            cell.membersTableViewDelegate = self
            cell.member = member
            cell.setContent()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.memberTableViewCell, for: indexPath) as!  MemberTableViewCell
        cell.membersTableViewDelegate = self
        cell.member = member
        cell.setContent()
        return cell

    }
}

extension DashboardViewController: MembersTableViewDelegate {
    func removeButtonTapped(cell: MemberTableViewCell?) {
        if let cell = cell {
            performSegue(withIdentifier: Constants.Storyboard.dashboardToRemoveUserSegue, sender: cell)
        }
    }

    func leaveButtonTapped( cell: CurrentMemberTableViewCell?) {
        if let cell = cell {
            performSegue(withIdentifier: Constants.Storyboard.dashboardToLeaveFlatSegue, sender: cell)
        }
    }
}

extension DashboardViewController: ChangeFlatNameDelegate {
    func updateFlatName() {
        if let flat = flat {
            flatNameLabel.text = flat.name
        }
    }
}

// MARK: Private

private extension DashboardViewController {
    func fetchMembers() {
        flat?.fetchMembers(currentUser: user!) { [weak self] in
            guard let self = self else { return }
            self.membersTableView.reloadData()
            self.membersTableViewHeightConstraint.constant = CGFloat(self.membersTableView.numberOfRows(inSection: 0) * 80)
            self.activityIndicator?.stopAnimating()
            self.view.layoutIfNeeded()
        }
    }

    func setupFeatures() {
        featureImages = [UIImage(named: "bell.small") ?? UIImage(),
                              UIImage(named: "stickers.small") ?? UIImage(),
                              UIImage(named: "coin.small") ?? UIImage()]

        featureNames = ["Board",
                             "Calendar",
                             "Finances"]

        featureSegueIdentifiers = [Constants.Storyboard.dashboardToBoardSegue,
                                        Constants.Storyboard.dashboardToCalendarSegue,
                                        Constants.Storyboard.dashboardToFinancesSegue]
    }

    func setupContent() {
        setupFeatures()
        if let flat = flat {
            flatNameLabel.text = flat.name
        }
    }
}
