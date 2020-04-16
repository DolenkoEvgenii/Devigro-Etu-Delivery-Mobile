//
// Created by Евгений Доленко on 2019-05-04.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

class GetProfileResponse: Codable {
    let id: String
    let fullName: FullName
    let phone: String
    let username: String
    let email: String?
    let error: String?
    let company: Company?

    class Company: Codable {
        let id: String
        let name: String
        let address: String
    }

    class FullName: Codable {
        let firstName: String?
        let lastName: String?
        let middleName: String?

        var fullName: String {
            return "\(lastName ?? "")  \(firstName ?? "")  \(middleName ?? "")"
        }
    }
}
