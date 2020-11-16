//
//  MaterialTextView.swift
//  cOlive
//
//  Created by Iga Hupalo on 08/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import UIKit
import JVFloatLabeledTextField

class MaterialTextView: JVFloatLabeledTextView {

    private let padding: CGFloat = 10
    private var hasError = false

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setup()
    }


    private func setup() {
        self.contentInset = UIEdgeInsets(top: 8, left: self.padding, bottom: 0, right: self.padding)
        self.floatingLabelYPadding = 5
    }

    // TODO: TextView error

    func setError(message: String) {
        if !hasError  {
//            self.layer.borderColor = self.errorColor.cgColor
        }

        hasError = true
        self.wiggle()
    }

    /// Function used for the removal of an existing error, fired on every beginning of editing text of a text field with error flag.

    @objc func removeMessages() {
        if hasError {
            hasError = false
//            self.layer.borderColor = self.self.leftPadding
//            self.layer.borderWidth = self.leftPadding
        }
    }

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
