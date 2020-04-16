//
// Created by Евгений Доленко on 2019-05-03.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

class ChangeOrderStatusRequest: Codable {
    let order_id: Int
    let status: Int

    init(order_id: Int, status: Int) {
        self.order_id = order_id
        self.status = status
    }
}