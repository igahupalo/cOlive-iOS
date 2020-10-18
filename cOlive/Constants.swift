//
//  Constants.swift
//  cOlive
//
//  Created by Iga Hupalo on 11/09/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation

struct Constants {

    struct Storyboard {
        static let homeViewController = "HomeVC"
        static let startViewController = "StartVC"
        static let loginViewController = "LoginVC"
        static let signUpViewController = "SignUpVC"
        static let startToLoginSegue = "StartToLoginSeg"
    }

    struct LoginErrorMessages {
        static let emptyEmail = "Email can't be empty"
        static let emptyPassword = "Password can't be empty"
        static let invalidEmail = "Email is invalid"
        static let incorrectEmailPassword = "Email or password is incorrect"
    }

    struct SignUpErrorMessages {
        static let emptyUsername = "Username can't be empty"
        static let emptyEmail = "Email can't be empty"
        static let emptyPassword = "Password can't be empty"
        static let takenEmail = "Account using this email already exists"
        static let invalidEmail = "Email is invalid"
        static let shortPassword = "Password must be at least 6 characters long"
    }
}
