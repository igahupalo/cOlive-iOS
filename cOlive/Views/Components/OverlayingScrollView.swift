//
//  OverlayingScrollView.swift
//  cOlive
//
//  Created by Iga Hupalo on 17/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import UIKit

class OverlayingScrollView: UIScrollView {
    var underlyingViewReference : UIView!

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        if underlyingViewReference.frame.contains(point) {
            return underlyingViewReference!.hitTest(point, with: event)
        }
        else {
            return super.hitTest(point, with: event)
        }
    }
}

