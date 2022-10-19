//
//  UIImage+Insets.swift
//  cOlive
//
//  Created by Iga Hupalo on 17/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func withInsets(_ insets: UIEdgeInsets) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom), false, self.scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return imageWithInsets
    }
}
