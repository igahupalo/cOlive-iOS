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

        setupFeatures()

        self.user?.fetchCurrent {
            self.flat = self.user?.membership?.flat
            self.setContent()
            if self.user == nil {
                self.user?.detachListeners()
                self.sessionManager.logOut()
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
