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
        // MARK: View Controllers.
        static let welcomeViewController = "WelcomeVC"
        static let homeViewController = "HomeVC"
        static let startViewController = "StartVC"
        static let loginViewController = "LoginVC"
        static let signUpViewController = "SignUpVC"

        // MARK: Navigation Controllers.
        static let mainNavigationController = "MainNC"

        // MARK: Segues.
        static let startToLoginSegue = "StartToLoginSeg"
        static let startToSignUpSegue = "StartToSignUpSeg"
        static let homeToFlatsSegue = "HomeToFlatsSeg"
        static let homeToProfileSegue = "HomeToProfileSeg"
        static let flatsToAddFlatSegue = "FlatsToAddFlatSeg"
        static let homeToCalendarSegue = "HomeToCalendarSeg"
    }

    struct StartTexts {
        static let titles = ["Start cOliving!",
                             "Split expenses",
                             "Calendar",
                             "Info board"]
        static let descriptions = ["Gather your housemates and never miss anything important.",
                                   "With cOlive you always know who owes who.",
                                   "Inform your housemates about your plans or make the cleaning schedule.",
                                   "Any announcement to make, but you can’t run into each other? Share it in the app!"]
    }

    struct LoginErrorMessages {
        static let emptyEmail = "Set your email to create an account"
        static let emptyPassword = "Set your password to create an account"
        static let invalidEmail = "Enter a valid email address"
        static let incorrectEmailPassword = "This email and password combination is incorrect."
    }

    struct SignUpErrorMessages {
        static let emptyUsername = "Set your username to create an account"
        static let emptyEmail = "Set your email to create an account"
        static let emptyPassword = "Set your password to create an account"
        static let takenEmail = "Account using this email already exists"
        static let invalidEmail = "Enter a valid email address"
        static let shortPassword = "Password must be at least 6 characters long"
    }

    struct AddFlatErrorMessages {
        static let emptyFlatName = "Set flat name to create a new flat"
    }
}
