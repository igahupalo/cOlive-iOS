//
//  HomeViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 11/09/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController {

    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var userGreetingLabel: UILabel!
    @IBOutlet weak var flatNameLabel: UILabel!
    @IBOutlet weak var featuresCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var membersTableView: UITableView!

    var user: User?
    var flat: Flat?

    private let sessionManager: SessionManager
    private var featureImages: [UIImage] = []
    private var featureNames: [String] = []
    private var featureSegueIdentifiers: [String] = []


    required init?(coder: NSCoder) {
        self.sessionManager = SessionManager()
        self.user = User()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = false
        membersTableView.tableFooterView = UIView()
        setupFeatures()

        self.user?.fetchCurrent {
            if self.user?.documentId == nil {
                self.user?.detachListeners()
                self.sessionManager.logOut()
                return
            }
            self.flat = self.user?.membership?.flat
            self.flat?.fetchMembers(currentUser: self.user!) {
                self.setContent()
                self.membersTableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isHidden = true
        self.setContent()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.homeToFlatsSegue:
            let flatsViewController = segue.destination as! FlatsViewController
            flatsViewController.user = self.user
        case Constants.Storyboard.homeToProfileSegue:
            let profileViewController = segue.destination as! ProfileViewController
            profileViewController.user = self.user
        case Constants.Storyboard.homeToCalendarSegue:
            let calendarViewController = segue.destination as! CalendarViewController
            calendarViewController.user = self.user
            calendarViewController.flat = self.flat
        default:
            break
        }
    }

    func setContent() {
        if let user = self.user {
            userGreetingLabel.text = "Hi, \(user.username)!"
            userImageButton.setImage(user.image, for: .normal)
            if let flat = self.flat {
                flatNameLabel.text = flat.name
            }
        }
    }

    func setupFeatures() {
        featureImages = [UIImage(named: "bell.small") ?? UIImage(),
                         UIImage(named: "coin.small") ?? UIImage(),
                         UIImage(named: "stickers.small") ?? UIImage()]

        featureNames = ["Board", "Finances", "Calendar"]

        featureSegueIdentifiers = [Constants.Storyboard.homeToBoardSegue,
                                   Constants.Storyboard.homeToFinancesSegue,
                                   Constants.Storyboard.homeToCalendarSegue]
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flat?.members.membersArray.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.memberTableViewCell) as! MemberTableViewCell
        let member = flat?.members.membersArray[indexPath.row]
        cell.member = member
        cell.setContent()

        return cell
    }
}
