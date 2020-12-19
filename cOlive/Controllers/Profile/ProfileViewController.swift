//
//  ProfileViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 25/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var userImageView: ProfileImageView!
    @IBOutlet weak var logOutStackView: UIStackView!
    @IBOutlet weak var removeAccountStackView: UIStackView!
    @IBOutlet weak var displayNameButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var birthdayButton: UIButton!
    @IBOutlet weak var flatsTableView: UITableView!
    @IBOutlet weak var flatsTableViewHeightConstraint: NSLayoutConstraint!

    weak var user: User?
    weak var listenerDetacherDelegate: ListenerDetacherDelegate?

    private var memberships: Memberships?
    private  var imagePicker: ImagePicker!
    private let sessionManager: SessionManager

    required init?(coder: NSCoder) {
        self.sessionManager = SessionManager()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupContent()
        self.setupMembershipsTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.memberships?.detachListeners()
        self.navigationController?.navigationBar.isHidden = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.profileToChangeNameSegue:
            let changeNameViewController = segue.destination as! ChangeNameViewController
            changeNameViewController.user = self.user
            changeNameViewController.changeNameDelegate = self
        case Constants.Storyboard.profileToChangePhoneNumberSegue:
            let changePhoneNumberViewController = segue.destination as! ChangePhoneNumberViewController
            changePhoneNumberViewController.user = self.user
            changePhoneNumberViewController.changePhoneNumberDelegate = self
        case Constants.Storyboard.profileToChangeBirthdaySegue:
            let changeBirthdayViewController = segue.destination as! ChangeBirthdayViewController
            changeBirthdayViewController.user = self.user
            changeBirthdayViewController.changeBirthdayDelegate = self
//        case Constants.Storyboard.profileToChangePasswordSegue:
//            let changePhoneNumberViewController = segue.destination as! ChangePhoneNumberViewController
//            changePhoneNumberViewController.user = self.user
//        case Constants.Storyboard.profileToChangeEmailSegue:
//            let changePhoneNumberViewController = segue.destination as! ChangePhoneNumberViewController
//            changePhoneNumberViewController.user = self.user
        case Constants.Storyboard.profileToCheckInOptionsSegue:
            let checkInOptionsViewController = segue.destination as! CheckInOptionsViewController
            checkInOptionsViewController.user = self.user
            checkInOptionsViewController.checkInOptionsDelegate = self
        case Constants.Storyboard.profileToCreateFlatSegue:
            let createFlatViewController = segue.destination as! CreateFlatViewController
            createFlatViewController.user = self.user
            createFlatViewController.listenerDetacherDelegate = self.listenerDetacherDelegate
            self.navigationController?.navigationBar.isHidden = false
        case Constants.Storyboard.profileToCheckInSegue:
            let checkInViewController = segue.destination as! CheckInViewController
            checkInViewController.user = self.user
            checkInViewController.listenerDetacherDelegate = self.listenerDetacherDelegate
            self.navigationController?.navigationBar.isHidden = false
        default:
            break
        }
    }

    func setupContent() {
        // Profile picture
        self.userImageView.user = self.user
        self.userImageView.hasEditIcon = true
        self.userImageView.setContent()

        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        let editImageTap = UITapGestureRecognizer(target: self, action: #selector(editImageTapped))
        self.userImageView.addGestureRecognizer(editImageTap)

        // Profile info
        self.displayNameButton.setTitle(self.user?.displayName, for: .normal)
        self.emailButton.setTitle(self.user?.email, for: .normal)

        if let birthday = self.user?.birthday {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            self.birthdayButton.setTitle(formatter.string(from: birthday), for: .normal)
            self.birthdayButton.setTitleColor(UIColor(named: "Black"), for: .normal)
        } else {
            self.birthdayButton.setTitle("Add", for: .normal)
            self.birthdayButton.setTitleColor(UIColor(named: "Black 30%"), for: .normal)
        }
        if let phoneNumber = self.user?.phoneNumber {
            self.phoneNumberButton.setTitle(phoneNumber, for: .normal)
            self.phoneNumberButton.setTitleColor(UIColor(named: "Black"), for: .normal)
        } else {
            self.phoneNumberButton.setTitle("Add", for: .normal)
            self.phoneNumberButton.setTitleColor(UIColor(named: "Black 30%"), for: .normal)
        }

        let logOutStackViewTap = UITapGestureRecognizer(target: self, action: #selector(logOutStackViewTapped))
        self.logOutStackView.addGestureRecognizer(logOutStackViewTap)
    }

    func setupMembershipsTableView() {
        self.memberships = Memberships()
        if let user = self.user {
            self.memberships?.fetch(user: user) {
                self.flatsTableViewHeightConstraint.constant = CGFloat((self.memberships?.membershipsArray.count ?? .zero) * 50)
                self.flatsTableView.reloadData()
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func editImageTapped(sender: UIGestureRecognizer) {
        self.imagePicker.present(from: self.userImageView)
    }

    @objc func logOutStackViewTapped(sender: UIGestureRecognizer) {
        self.listenerDetacherDelegate?.detachListeners()
        self.listenerDetacherDelegate?.detachMembershipsListener()
        self.sessionManager.logOut()
    }
    
    @IBAction func crossButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        self.user?.image = image
        self.userImageView.setContent()
        self.user?.saveImage { _ in }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource, MembershipTableViewDelegate {
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
                self?.listenerDetacherDelegate?.detachMembershipsListener()
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// TODO: Eliminate code repetition
extension ProfileViewController: ChangeNameDelegate, ChangePhoneNumberDelegate, ChangeBirthdayDelegate {
    func updateDisplayName() {
        self.displayNameButton.setTitle(self.user?.displayName, for: .normal)
    }

    func updatePhoneNumber() {
        if let phoneNumber = self.user?.phoneNumber {
            self.phoneNumberButton.setTitle(phoneNumber, for: .normal)
            self.phoneNumberButton.setTitleColor(UIColor(named: "Black"), for: .normal)
        } else {
            self.phoneNumberButton.setTitle("Add", for: .normal)
            self.phoneNumberButton.setTitleColor(UIColor(named: "Black 30%"), for: .normal)
        }
    }

    func updateBirthday() {
        if let birthday = self.user?.birthday {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            self.birthdayButton.setTitle(formatter.string(from: birthday), for: .normal)
            self.birthdayButton.setTitleColor(UIColor(named: "Black"), for: .normal)
        } else {
            self.birthdayButton.setTitle("Add", for: .normal)
            self.birthdayButton.setTitleColor(UIColor(named: "Black 30%"), for: .normal)
        }
    }
}

extension ProfileViewController: CheckInOptionsDelegate {
    func checkInTapped() {
        self.performSegue(withIdentifier: Constants.Storyboard.profileToCheckInSegue, sender: self)
    }

    func createFlatTapped() {
        self.performSegue(withIdentifier: Constants.Storyboard.profileToCreateFlatSegue, sender: self)
    }
}
