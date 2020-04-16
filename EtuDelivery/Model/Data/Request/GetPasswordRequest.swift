//
// Created by Евгений Доленко on 2019-05-03.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

class GetPasswordRequest: Codable {
    let phone: String

    init(phone: String) {
        self.phone = phone
    }
}