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

class HomeViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var userImageView: ProfileImageView!
    @IBOutlet weak var userGreetingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userGreetingActivityIndicator: UIActivityIndicatorView!

    var user = User()

    private var isFirstTimeLoad = false
    private let sessionManager = SessionManager()
    private var containerContent: UIViewController?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupContent()
        isFirstTimeLoad = true
        fetchCurrentUser()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        user.detachProfileListener()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        if !isFirstTimeLoad {
            user.addProfileListener { [weak self] in
                guard let self = self else { return }
                self.setupUserInfo()
                (self.containerContent as? DashboardViewController)?.reload()
            }
        }
        isFirstTimeLoad = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.homeToProfileSegue:
            let navigationController = segue.destination as! UINavigationController
            let profileViewController = navigationController.viewControllers.first as! ProfileViewController
            profileViewController.user = user
            profileViewController.listenerDetacherDelegate = self
        default:
            break
        }
    }

    // MARK: - Event handlers

    @objc func userImageTapped(sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: Constants.Storyboard.homeToProfileSegue, sender: self)
    }

    @IBAction func unwindToDashboard( _ seg: UIStoryboardSegue) {}

}

// MARK: - Listener Detacher Delegate

extension HomeViewController: ListenerDetacherDelegate {

    func detachListeners() {
        user.detachMembershipListener()
    }

    func detachMembershipsListener() {
        (containerContent as? FlatlessDashboardViewController)?.memberships?.detachListeners()
    }
}

// MARK: Private

private extension HomeViewController {
    func fetchCurrentUser() {
        user.fetchCurrent { [weak self] in
            guard let self = self else { return }

            if self.user.documentId == nil {
                self.sessionManager.logOut()
                return
            }
            self.setupUserInfo()
            self.setupViewContainer()
            self.user.addMembershipListener {
                self.setupViewContainer()
            }
            self.user.addProfileListener {
                self.setupUserInfo()
                (self.containerContent as? DashboardViewController)?.reload()
            }
        }
    }

    func setupContent() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        let userImageTap = UITapGestureRecognizer(target: self, action: #selector(userImageTapped))
        userImageView.addGestureRecognizer(userImageTap)
        activityIndicator.isHidden = false
        setupContainerShadow()
    }

    func setupViewContainer() {
        user.membership?.flat.detachListeners()
        (containerContent as? FlatlessDashboardViewController)?.memberships?.detachListeners()
        containerContent?.removeFromParent()
        containerContent?.view.subviews.forEach({ $0.removeFromSuperview() })
        if user.membershipId != nil {
            setupDashboard()
        } else {
            setupFlatlessDashboard()
        }
    }

    func setupDashboard() {
        // TODO: Set up constants
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let dashboardViewController: DashboardViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.dashboardViewController) as! DashboardViewController
        dashboardViewController.user = user
        dashboardViewController.activityIndicator = activityIndicator
        containerContent = dashboardViewController
        addChild(dashboardViewController)
        containerView.addSubview(dashboardViewController.view)
    }

    func setupFlatlessDashboard() {
        // TODO: Set up constants
        let storyboard = UIStoryboard(name: "FlatlessDashboard", bundle: nil)
        let flatlessDashboardViewController: FlatlessDashboardViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.flatlessDashboardViewController) as! FlatlessDashboardViewController
        flatlessDashboardViewController.user = user
        flatlessDashboardViewController.activityIndicator = activityIndicator
        flatlessDashboardViewController.view.frame = containerView.bounds
        containerContent = flatlessDashboardViewController
        addChild(flatlessDashboardViewController)
        containerView.addSubview(flatlessDashboardViewController.view)
    }

    func setupUserInfo() {
        userImageView.user = user
        userImageView.setContent()
        userGreetingActivityIndicator.stopAnimating()
        userGreetingLabel.text = "Hi, \(user.displayName)!"
        userGreetingLabel.isHidden = false
    }

    func setupContainerShadow() {
        let shadowLayer = containerView.layer
        // TODO: Set up constants
        shadowLayer.shadowColor = UIColor(red: 0.149, green: 0.251, blue: 0.229, alpha: 0.1).cgColor
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = 20
        shadowLayer.shadowOffset = CGSize(width: 0, height: -10)
        containerView.layer.masksToBounds = false
    }
}
