//
//  FormPopoverViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 22/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
import UIKit

class FormPopoverViewController: UIViewController, UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let distance = self.view.bounds.height - textField.frame.origin.y - textField.bounds.height
        IQKeyboardManager.shared.keyboardDistanceFromTextField = distance
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 10
        return true
    }
    
}
