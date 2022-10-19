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
        static let dashboardViewController = "DashboardVC"
        static let flatlessDashboardViewController = "FlatlessDashboardVC"


        // MARK: Navigation Controllers.
        static let mainNavigationController = "MainNC"
        static let checkInOptionsNavigationController = "CheckInOptionsNC"

        // MARK: Segues.
        static let startToLoginSegue = "StartToLoginSeg"
        static let startToSignUpSegue = "StartToSignUpSeg"
        static let homeToDashboardSegue = "HomeToDashboardSeg"
        static let homeToNoFlatSegue = "HomeToNoFlatboardSeg"
        static let homeToFlatsSegue = "HomeToFlatsSeg"
        static let homeToProfileSegue = "HomeToProfileSeg"
        static let dashboardToInviteSegue = "DashboardToInviteSeg"
        static let dashboardToLeaveFlatSegue = "DashboardToLeaveFlatSeg"
        static let dashboardToRemoveUserSegue = "DashboardToRemoveUserSeg"
        static let dashboardToFinancesSegue = "DashboardToFinancesSeg"
        static let dashboardToCalendarSegue = "DashboardToCalendarSeg"
        static let dashboardToChangeFlatNameSegue = "DashboardToChangeFlatNameSeg"
        static let flatlessDashboardToCreateFlatSegue = "FlatlessDashboardToCreateFlatSeg"
        static let flatlessDashboardToCheckInSegue = "FlatlessDashboardToCheckInSeg"
        static let createFlatToInviteSegue = "CreateFlatToInviteSeg"
        static let dashboardToBoardSegue = "DashboardToBoardSeg"
        static let flatsToAddFlatSegue = "FlatsToAddFlatSeg"
        static let calendarToEditEventSegue = "CalendarToEditEventSeg"
        static let calendarToEventSegue = "CalendarToEventSeg"
        static let eventToEditEventSegue = "EventToEditEventSeg"
        static let boardToEditPostSegue = "BoardToEditPostSeg"
        static let boardToPostSegue = "BoardToPostSeg"
        static let postToEditPostSegue = "PostToEditPostSeg"
        static let profileToChangeNameSegue = "ProfileToChangeNameSeg"
        static let profileToChangeEmailSegue = "ProfileToChangeEmailSeg"
        static let profileToChangePasswordSegue = "ProfileToChangePasswordSeg"
        static let profileToChangePhoneNumberSegue = "ProfileToChangePhoneNumberSeg"
        static let profileToChangeBirthdaySegue = "ProfileToChangeBirthdaySeg"
        static let profileToCheckInOptionsSegue = "ProfileToCheckInOptionsSeg"
        static let profileToCreateFlatSegue = "ProfileToCreateFlatSeg"
        static let profileToCheckInSegue = "ProfileToCheckInSeg"

        // MARK: Constraints.
        static let flatsStackViewTopConstraint = "flatsStackViewTopCons"
        static let flatsStackViewBottomConstraint = "flatsStackViewBottomCons"
        static let flatsStackViewVerticalCenterConstraint = "flatsStackViewVerticalCenterCons"
    }

    struct CellIdentifiers {
        static let flatTableViewCell = "FlatTableViewCell"
        static let featureCollectionViewCell = "FeatureCollectionViewCell"
        static let eventTableViewCell = "EventTableViewCell"
        static let postTableViewCell = "PostTableViewCell"
        static let memberTableViewCell = "MemberTableViewCell"
        static let commentTableViewCell = "CommentTableViewCell"
        static let currentMemberTableViewCell = "CurrentMemberTableViewCell"
    }

    struct AuthOptionsTexts {
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
        static let emptyName = "Set your name to create an account"
        static let emptyEmail = "Set your email to create an account"
        static let emptyPassword = "Set your password to create an account"
        static let takenEmail = "Account using this email already exists"
        static let invalidEmail = "Enter a valid email address"
        static let shortPassword = "Password must be at least 6 characters long"
    }

    struct AddFlatErrorMessages {
        static let emptyFlatName = "Set flat name to create a new flat"
    }

    struct CheckInErrorMessages {
        static let shortCode = "Enter 5-digit code to check-in"
        static let invalidCode = "Invalid invitation code"
        static let alreadyMember = "You're already a member of this flat group"
    }

    struct AddEventErrorMessages {
        static let emptyEventTitle = "Set title to create a new event"
        static let alertTitle = "Something went wrong"
        static let alertMessage = "An error occured while adding your event to the calendar. Try again."
        static let alertButton = "OK"
    }

    struct EditPostErrorMessages {
        static let emptyPostTitle = "Set title to create a new post"
    }

    struct FormPopoversErrorMessages {
        static let emptyName = "Set your new name"
        static let emptyOldPassword = "Provide your old password"
        static let emptyNewPassword = "Provide your new password"
        static let emptyFlatName = "Set new flat name"
    }

    struct InviteTexts {
        static let shareMessage = "I invite you to share %@ flat group with me in cOlive app. You can check-in using code: %@"
    }

    struct Colors {
        static let tintColorName = "mint-dark"
    }
}
