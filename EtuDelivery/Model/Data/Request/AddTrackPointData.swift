//
// Created by Евгений Доленко on 2019-05-03.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import RealmSwift

class AddTrackPointData: Object, Codable {
    @objc dynamic var order_id: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lng: Double = 0.0
    @objc dynamic var comment: String = ""
    @objc dynamic var createdAt: String = ""
}