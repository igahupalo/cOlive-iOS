//
//  Validator.swift
//  cOlive
//
//  Created by Iga Hupalo on 14/10/2022.
//  Copyright © 2022 Iga Hupalo. All rights reserved.
//

import Foundation

class Validator {
    enum Response {
        case short
        case empty
        case incorrect
        case valid
    }

    func validateDisplayName(_ displayName: String?) -> Response {
        if displayName != nil && !displayName!.isEmpty {
           return .valid
        }
        return .empty
    }

    func validateEmail(_ email: String?) -> Response {
        if email != nil && !email!.isEmpty {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            if !emailPredicate.evaluate(with: email) {
                return .incorrect
            }
            return .valid
        }
        return .empty
    }

    func validatePassword(_ password: String?) -> Response {
        if password != nil && !password!.isEmpty {
            if password!.count < 6 {
                return .short
            }
            return .valid
        }
        return .empty
    }
}
