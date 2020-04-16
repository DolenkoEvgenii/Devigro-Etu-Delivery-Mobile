//
// Created by Евгений Доленко on 2019-05-03.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

class UpdateDeliveryDateRequest: Codable {
    let order_id: Int
    let interval_from: Int64
    let interval_to: Int64

    init(order_id: Int, interval_from: Int64, interval_to: Int64) {
        self.order_id = order_id
        self.interval_from = interval_from
        self.interval_to = interval_to
    }
}