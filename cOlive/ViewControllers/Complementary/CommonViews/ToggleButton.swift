//
//  ToggleButton.swift
//  cOlive
//
//  Created by Iga Hupalo on 09/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import UIKit

class ToggleButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }

    func initButton() {
        addTarget(self, action: #selector(ToggleButton.buttonPressed), for: .touchUpInside)
        isSelected = false
    }

    @objc func buttonPressed() {
        isSelected.toggle()
    }
}
