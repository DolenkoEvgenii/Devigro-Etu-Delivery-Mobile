//
// Created by Евгений Доленко on 15.01.2020.
// Copyright (c) 2020 Евгений Доленко. All rights reserved.
//

import Foundation

class AddTrackPointRequest: Codable {
    let point: GeoPoint
    let status: String
    let comment: String?
    let createdAt: String?

    init(point: GeoPoint, status: String, comment: String?, createdAt: String?) {
        self.point = point
        self.status = status
        self.comment = comment
        self.createdAt = createdAt
    }
}