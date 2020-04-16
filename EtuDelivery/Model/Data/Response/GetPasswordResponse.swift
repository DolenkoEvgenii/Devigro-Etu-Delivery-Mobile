//
// Created by Евгений Доленко on 2019-05-04.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

class GetPasswordResponse: Codable {
    let success: Bool
    let profileStatus: Int?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case success
        case profileStatus = "profile_status"
        case error
    }
}
