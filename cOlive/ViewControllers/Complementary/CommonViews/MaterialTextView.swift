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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setup()
    }

    private func setup() {
        self.contentInset = UIEdgeInsets(top: 8, left: self.padding, bottom: 0, right: self.padding)
        self.floatingLabelYPadding = 5
    }
}
