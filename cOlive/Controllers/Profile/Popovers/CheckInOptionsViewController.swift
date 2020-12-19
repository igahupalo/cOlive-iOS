//
//  CheckInOptionsViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 29/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

protocol CheckInOptionsDelegate: class {
    func checkInTapped()
    func createFlatTapped()
}

class CheckInOptionsViewController: UIViewController {

    weak var user: User?
    weak var checkInOptionsDelegate: CheckInOptionsDelegate?


    @IBAction func createFlatTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.checkInOptionsDelegate?.createFlatTapped()
        }
    }

    @IBAction func checkInTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.checkInOptionsDelegate?.checkInTapped()
        }
    }


//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch segue.identifier {
//        case Constants.Storyboard.checkInOptionsToCreateFlatSegue:
//            let createFlatViewController = segue.destination as! CreateFlatViewController
//            createFlatViewController.user = self.user
//        case Constants.Storyboard.checkInOptionsToCheckInSegue:
//            let checkInViewController = segue.destination as! CheckInViewController
//            checkInViewController.user = self.user
//        default:
//            break
//        }
//    }

}
