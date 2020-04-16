//
// Created by Евгений Доленко on 2019-05-04.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

class LoginResponse: Codable {
    let error: String?
    var token: String?

    enum CodingKeys: String, CodingKey {
        case error
        case token
    }
}
