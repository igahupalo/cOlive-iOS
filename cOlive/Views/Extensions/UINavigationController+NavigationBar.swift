//
//  UIViewController+NavigationBar.swift
//  cOlive
//
//  Created by Iga Hupalo on 14/09/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    func hideNavigationItemBackground() {
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = UIColor.clear
    }
}
