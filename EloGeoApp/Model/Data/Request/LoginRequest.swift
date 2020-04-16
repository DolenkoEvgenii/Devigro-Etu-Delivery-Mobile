//
// Created by Евгений Доленко on 2019-05-03.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

class LoginRequest: Codable {
    let phone: String?
    let username: String?
    let password: String

    init(username: String, password: String) {
        self.username = username
        self.password = password
        self.phone = nil
    }

    init(phone: String, password: String) {
        self.phone = phone
        self.password = password
        self.username = nil
    }
}