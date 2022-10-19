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
    private var imagePicker: ImagePicker!
    private let sessionManager = SessionManager()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupContent()
        setupMembershipsTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        memberships?.detachListeners()
        navigationController?.navigationBar.isHidden = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.profileToChangeNameSegue:
            let changeNameViewController = segue.destination as! ChangeNameViewController
            changeNameViewController.user = user
            changeNameViewController.changeNameDelegate = self
        case Constants.Storyboard.profileToChangePhoneNumberSegue:
            let changePhoneNumberViewController = segue.destination as! ChangePhoneNumberViewController
            changePhoneNumberViewController.user = user
            changePhoneNumberViewController.changePhoneNumberDelegate = self
        case Constants.Storyboard.profileToChangeBirthdaySegue:
            let changeBirthdayViewController = segue.destination as! ChangeBirthdayViewController
            changeBirthdayViewController.user = user
            changeBirthdayViewController.changeBirthdayDelegate = self
        case Constants.Storyboard.profileToCheckInOptionsSegue:
            let checkInOptionsViewController = segue.destination as! CheckInOptionsViewController
            checkInOptionsViewController.user = user
            checkInOptionsViewController.checkInOptionsDelegate = self
        case Constants.Storyboard.profileToCreateFlatSegue:
            let createFlatViewController = segue.destination as! CreateFlatViewController
            createFlatViewController.user = user
            createFlatViewController.listenerDetacherDelegate = listenerDetacherDelegate
            navigationController?.navigationBar.isHidden = false
        case Constants.Storyboard.profileToCheckInSegue:
            let checkInViewController = segue.destination as! CheckInViewController
            checkInViewController.user = user
            checkInViewController.listenerDetacherDelegate = listenerDetacherDelegate
            navigationController?.navigationBar.isHidden = false
        default:
            break
        }
    }

    // MARK: Handlers

    @objc func editImageTapped(sender: UIGestureRecognizer) {
        imagePicker.present(from: userImageView)
    }

    @objc func logOutStackViewTapped(sender: UIGestureRecognizer) {
        listenerDetacherDelegate?.detachListeners()
        listenerDetacherDelegate?.detachMembershipsListener()
        sessionManager.logOut()
    }
    
    @IBAction func crossButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        user?.image = image
        userImageView.setContent()
        user?.saveImage { _ in }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource, MembershipTableViewDelegate {
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

    func enterButtonTapped(cell: MembershipTableViewCell?) {
        if let membershipId = cell?.membership?.documentId {
            user?.setMembership(membershipId: membershipId) { [weak self] in
                self?.listenerDetacherDelegate?.detachMembershipsListener()
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension ProfileViewController: ChangeNameDelegate, ChangePhoneNumberDelegate, ChangeBirthdayDelegate {
    func updateDisplayName() {
        displayNameButton.setTitle(user?.displayName, for: .normal)
    }

    func updatePhoneNumber() {
        if let phoneNumber = user?.phoneNumber {
            phoneNumberButton.setTitle(phoneNumber, for: .normal)
            phoneNumberButton.setTitleColor(UIColor(named: "Black"), for: .normal)
        } else {
            phoneNumberButton.setTitle("Add", for: .normal)
            phoneNumberButton.setTitleColor(UIColor(named: "Black 30%"), for: .normal)
        }
    }

    func updateBirthday() {
        if let birthday = user?.birthday {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            birthdayButton.setTitle(formatter.string(from: birthday), for: .normal)
            birthdayButton.setTitleColor(UIColor(named: "Black"), for: .normal)
        } else {
            birthdayButton.setTitle("Add", for: .normal)
            birthdayButton.setTitleColor(UIColor(named: "Black 30%"), for: .normal)
        }
    }
}

extension ProfileViewController: CheckInOptionsDelegate {
    func checkInTapped() {
        performSegue(withIdentifier: Constants.Storyboard.profileToCheckInSegue, sender: self)
    }

    func createFlatTapped() {
        performSegue(withIdentifier: Constants.Storyboard.profileToCreateFlatSegue, sender: self)
    }
}

// MARK: Private

private extension ProfileViewController {
    func setupContent() {
        setupProfileImage()
        displayNameButton.setTitle(user?.displayName, for: .normal)
        emailButton.setTitle(user?.email, for: .normal)
        setupBirthdayButton()
        setupPhoneButton()

        let logOutStackViewTap = UITapGestureRecognizer(target: self, action: #selector(logOutStackViewTapped))
        logOutStackView.addGestureRecognizer(logOutStackViewTap)
    }

    func setupProfileImage() {
        userImageView.user = user
        userImageView.hasEditIcon = true
        userImageView.setContent()

        imagePicker = ImagePicker(presentationController: self, delegate: self)
        let editImageTap = UITapGestureRecognizer(target: self, action: #selector(editImageTapped))
        userImageView.addGestureRecognizer(editImageTap)
    }

    func setupBirthdayButton() {
        if let birthday = user?.birthday {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            birthdayButton.setTitle(formatter.string(from: birthday), for: .normal)
            birthdayButton.setTitleColor(.black, for: .normal)
        } else {
            birthdayButton.setTitle("Add", for: .normal)
            birthdayButton.setTitleColor(UIColor(named: "black-opaque"), for: .normal)
        }
    }

    func setupPhoneButton() {
        if let phoneNumber = user?.phoneNumber {
            phoneNumberButton.setTitle(phoneNumber, for: .normal)
            phoneNumberButton.setTitleColor(.black, for: .normal)
        } else {
            phoneNumberButton.setTitle("Add", for: .normal)
            phoneNumberButton.setTitleColor(UIColor(named: "black-opaque"), for: .normal)
        }
    }

    func setupMembershipsTableView() {
        memberships = Memberships()
        if let user = user {
            memberships?.fetch(user: user) { [weak self] in
                guard let self = self else { return }
                self.flatsTableViewHeightConstraint.constant = CGFloat((self.memberships?.membershipsArray.count ?? .zero) * 50)
                self.flatsTableView.reloadData()
                self.view.layoutIfNeeded()
            }
        }
    }
}
