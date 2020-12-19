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
        let wiggleAnim = CABasicAnimation(keyPath: "position")
        wiggleAnim.duration = 0.05
        wiggleAnim.repeatCount = 4
        wiggleAnim.autoreverses = true
        wiggleAnim.fromValue = CGPoint(x: self.center.x - 3.0, y: self.center.y)
        wiggleAnim.toValue = CGPoint(x: self.center.x + 3.0, y: self.center.y)
        layer.add(wiggleAnim, forKey: "position")
    }
}
