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

    @IBOutlet weak var userImageView: ProfileImageView!
    @IBOutlet weak var userGreetingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: OverlayingScrollView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    var user: User?

    private var isLoadedFirstTime = false
    private let sessionManager: SessionManager
    private var containerContent: UIViewController?

    required init?(coder: NSCoder) {
        self.sessionManager = SessionManager()
        self.user = User()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hideHairline()
//        self.navigationController?.hideNavigationItemBackground()
        let userImageTap = UITapGestureRecognizer(target: self, action: #selector(userImageTapped))
        self.userImageView.addGestureRecognizer(userImageTap)
        self.scrollView.underlyingViewReference = self.userImageView
        self.activityIndicator.isHidden = false
        self.setupContainerShadow()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.isLoadedFirstTime = true
        self.user?.fetchCurrent {
            if self.user?.documentId == nil {
                self.sessionManager.logOut()
                return
            }
            self.setupUserInfo()
            self.setupViewContainer()
            self.user?.addMembershipListener {
                self.setupViewContainer()
            }
            self.user?.addProfileListener {
                self.setupUserInfo()
                (self.containerContent as? DashboardViewController)?.reload()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.user?.detachProfileListener()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        if !self.isLoadedFirstTime {
            self.user?.addProfileListener {
                self.setupUserInfo()
                (self.containerContent as? DashboardViewController)?.reload()
            }
        }
        self.isLoadedFirstTime = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.homeToProfileSegue:
            let navigationController = segue.destination as! UINavigationController
            let profileViewController = navigationController.viewControllers.first as! ProfileViewController
            profileViewController.user = self.user
            profileViewController.listenerDetacherDelegate = self
        default:
            break
        }
    }

    private func setupViewContainer() {
        self.user?.membership?.flat.detachListeners()
        (self.containerContent as? FlatlessDashboardViewController)?.memberships?.detachListeners()
        self.containerContent?.removeFromParent()
        self.containerContent?.view.subviews.forEach({ $0.removeFromSuperview() })
        if self.user?.membershipId != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let dashboardViewController: DashboardViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.dashboardViewController) as! DashboardViewController
            dashboardViewController.user = self.user
            dashboardViewController.activityIndicator = self.activityIndicator
            dashboardViewController.containerViewHeightDelegate = self
            self.containerContent = dashboardViewController
            self.addChild(dashboardViewController)
            self.containerView.addSubview(dashboardViewController.view)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.containerViewHeightConstraint.constant = self.view.frame.height - 120
            let flatlessDashboardViewController: FlatlessDashboardViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.flatlessDashboardViewController) as! FlatlessDashboardViewController
            flatlessDashboardViewController.user = self.user
            flatlessDashboardViewController.activityIndicator = self.activityIndicator
            flatlessDashboardViewController.view.frame = self.containerView.bounds
            self.containerContent = flatlessDashboardViewController
            self.addChild(flatlessDashboardViewController)
            self.containerView.addSubview(flatlessDashboardViewController.view)
        }
    }

    private func setupUserInfo() {
        self.userImageView.user = self.user
        self.userImageView.setContent()
        self.userGreetingLabel.text = "Hi, \(self.user?.displayName ?? "user")!"
    }

    private func setupContainerShadow() {

        let shadowLayer = self.containerView.layer
        shadowLayer.shadowColor = UIColor(red: 0.149, green: 0.251, blue: 0.229, alpha: 0.1).cgColor
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = 20
        shadowLayer.shadowOffset = CGSize(width: 0, height: -10)
        self.containerView.layer.masksToBounds = false
    }

    @objc func userImageTapped(sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: Constants.Storyboard.homeToProfileSegue, sender: self)
      }

    @IBAction func unwindToDashboard( _ seg: UIStoryboardSegue) {}

}

extension HomeViewController: ContainerViewHeightDelegate {
    func updateHeight(height: CGFloat) {
        if height + 120 < self.view.frame.height {
            self.containerViewHeightConstraint.constant = self.view.frame.height - 120
        } else {
            self.containerViewHeightConstraint.constant = height

        }
    }
}

extension HomeViewController: ListenerDetacherDelegate {
    func detachListeners() {
        self.user?.detachMembershipListener()
    }

    func detachMembershipsListener() {
        (self.containerContent as? FlatlessDashboardViewController)?.memberships?.detachListeners()
    }
}

protocol ListenerDetacherDelegate: class {
    func detachListeners()
    func detachMembershipsListener()
}
