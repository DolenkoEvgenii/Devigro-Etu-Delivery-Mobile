//
// Created by Евгений Доленко on 2019-05-04.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

struct RuntimeError: Error {
    let message: String


    init(_ message: String) {
        self.message = message
    }
}

extension Error {
    var message: String {
        if let myError = self as? RuntimeError {
            return myError.message
        } else {
            return "unknown_error".localized()
        }
    }
}