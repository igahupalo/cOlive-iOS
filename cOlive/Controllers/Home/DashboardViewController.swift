//
//  DashboardViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 16/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

protocol ContainerViewHeightDelegate: class {
    func updateHeight(height: CGFloat)
}

class DashboardViewController: UIViewController {

    @IBOutlet weak var featuresCollectionView: UICollectionView!
    @IBOutlet weak var membersTableView: UITableView!
    @IBOutlet weak var flatNameLabel: UILabel!
    @IBOutlet weak var membersTableViewHeightConstraint: NSLayoutConstraint!

    weak var activityIndicator: UIActivityIndicatorView?

    weak var user: User?
    weak var flat: Flat?
    weak var containerViewHeightDelegate: ContainerViewHeightDelegate?

    private var featureImages: [UIImage] = []
    private var featureNames: [String] = []
    private var featureSegueIdentifiers: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.flat = self.user?.membership?.flat
        self.setContent()
        self.flat?.fetchMembers(currentUser: self.user!) {
            self.membersTableView.reloadData()
            self.membersTableViewHeightConstraint.constant = CGFloat(self.membersTableView.numberOfRows(inSection: 0) * 80)
            self.containerViewHeightDelegate?.updateHeight(height: self.membersTableView.frame.origin.y + self.membersTableViewHeightConstraint.constant)
            self.activityIndicator?.stopAnimating()
            self.view.layoutIfNeeded()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.setContent()
        self.membersTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.dashboardToCalendarSegue:
            let calendarViewController = segue.destination as! CalendarViewController
            calendarViewController.user = self.user
            calendarViewController.flat = self.flat
        case Constants.Storyboard.dashboardToBoardSegue:
            let boardViewController = segue.destination as! BoardViewController
            boardViewController.user = self.user
            boardViewController.flat = self.flat
        case Constants.Storyboard.dashboardToRemoveUserSegue:
            let removeUserViewController = segue.destination as! RemoveUserViewController
            removeUserViewController.member = (sender as! MemberTableViewCell).member
            removeUserViewController.flat = self.flat
        case Constants.Storyboard.dashboardToLeaveFlatSegue:
            let leaveFlatViewController = segue.destination as! LeaveFlatViewController
            leaveFlatViewController.member = (sender as! CurrentMemberTableViewCell).member
            leaveFlatViewController.flat = self.flat
        case Constants.Storyboard.dashboardToChangeFlatNameSegue:
            let changeFlatNameViewController = segue.destination as! ChangeFlatNameViewController
            changeFlatNameViewController.flat = self.flat
            changeFlatNameViewController.changeFlatNameDelegate = self
        case Constants.Storyboard.dashboardToInviteSegue:
            let inviteViewController = segue.destination as! InviteViewController
            inviteViewController.flat = self.flat
        default:
            break
        }
    }

    func reload() {
        self.membersTableView.reloadData()
    }

    func setupFeatures() {
        self.featureImages = [UIImage(named: "bell.small") ?? UIImage(),
                         UIImage(named: "coin.small") ?? UIImage(),
                         UIImage(named: "stickers.small") ?? UIImage()]

        self.featureNames = ["Board", "Finances", "Calendar"]

        self.featureSegueIdentifiers = [Constants.Storyboard.dashboardToBoardSegue,
                                   Constants.Storyboard.dashboardToFinancesSegue,
                                   Constants.Storyboard.dashboardToCalendarSegue]
    }

    func setContent() {
        self.setupFeatures()
        if let flat = self.flat {
            flatNameLabel.text = flat.name
        }
    }
}

extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.featureNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = featuresCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifiers.featureCollectionViewCell, for: indexPath) as! FeatureCollectionViewCell

        cell.imageView.image = featureImages[indexPath.row]
        cell.nameLabel.text = featureNames[indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: featureSegueIdentifiers[indexPath.row], sender: self)
    }

}

extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return flat?.members?.membersArray.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        guard let member = flat?.members?.membersArray[indexPath.row] else {
            return UITableViewCell()
        }

        if member.userId == user?.documentId {
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
            self.performSegue(withIdentifier: Constants.Storyboard.dashboardToRemoveUserSegue, sender: cell)
        }
    }

    func leaveButtonTapped( cell: CurrentMemberTableViewCell?) {
        if let cell = cell {
            self.performSegue(withIdentifier: Constants.Storyboard.dashboardToLeaveFlatSegue, sender: cell)
        }
    }
}

extension DashboardViewController: ChangeFlatNameDelegate {
    func updateFlatName() {
        if let flat = self.flat {
            flatNameLabel.text = flat.name
        }
    }
}
