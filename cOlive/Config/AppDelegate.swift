//
//  AppDelegate.swift
//  cOlive
//
//  Created by Iga Hupalo on 09/09/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        setupFirebase()
        setupKeyboardManager()
        customizeNavigationBar()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

private extension AppDelegate {
    func setupFirebase() {
        FirebaseApp.configure()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        Firestore.firestore().settings = settings
    }

    func setupKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 10.0
    }

    func customizeNavigationBar() {
        let font = UIFont(name: "Now-Medium", size: 14.0) ?? UIFont()
        let largeFont = UIFont(name: "Now-Bold", size: 28.0) ?? UIFont()
        let style = UINavigationBarAppearance()
        style.buttonAppearance.normal.titleTextAttributes = [.font: font]
        style.doneButtonAppearance.normal.titleTextAttributes = [.font: font]
        style.titleTextAttributes = [.font: font]
        style.largeTitleTextAttributes = [.font: largeFont]
        style.setBackIndicatorImage(UIImage(named: "back"), transitionMaskImage: UIImage(named: "back"))
        style.backgroundColor = .systemBackground
        UINavigationBar.appearance().standardAppearance = style
        UINavigationBar.appearance().layoutMargins.left = 24
        UINavigationBar.appearance().layoutMargins.right = 24
        UINavigationBar.appearance().isTranslucent = true
    }
}
