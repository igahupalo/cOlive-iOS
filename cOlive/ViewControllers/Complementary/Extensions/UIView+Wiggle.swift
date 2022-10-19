//
//  UIView+Wiggle.swift
//  cOlive
//
//  Created by Iga Hupalo on 17/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func wiggle() {
        let wiggleAnimation = CABasicAnimation(keyPath: "position")
        wiggleAnimation.duration = 0.05
        wiggleAnimation.repeatCount = 4
        wiggleAnimation.autoreverses = true
        wiggleAnimation.fromValue = CGPoint(x: center.x - 3.0, y: center.y)
        wiggleAnimation.toValue = CGPoint(x: center.x + 3.0, y: center.y)
        layer.add(wiggleAnimation, forKey: "position")
    }
}
