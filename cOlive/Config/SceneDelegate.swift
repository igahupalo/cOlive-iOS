//
//  SceneDelegate.swift
//  cOlive
//
//  Created by Iga Hupalo on 09/09/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        // Creates listener handling authentication events.
        addAuthListener()

        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

private extension SceneDelegate {
    func addAuthListener() {
        _ = Auth.auth().addStateDidChangeListener { auth, user in
            let main = UIStoryboard(name: "Home", bundle: nil)
            let authentication = UIStoryboard(name: "Welcome", bundle: nil)
            let root = user != nil ?
            main.instantiateViewController(identifier: Constants.Storyboard.mainNavigationController)
            : authentication.instantiateViewController(identifier: Constants.Storyboard.welcomeViewController)
            self.window?.rootViewController = root
            DispatchQueue.main.async { self.window?.makeKeyAndVisible() }
        }
    }
}

