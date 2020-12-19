//
//  LeaveFlatViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 17/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class LeaveFlatViewController: UIViewController {

    weak var member: Member?
    var flat: Flat?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func leaveButtonTapped(_ sender: Any) {
        if let flat = self.flat {
            self.member?.removeFrom(flat: flat) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func stayButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
