//
// Created by Евгений Доленко on 30.11.2019.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

class ChatModel {
    let orderId: Int
    let managerId: Int

    var messages: [Message] = []

    init(orderId: Int, managerId: Int) {
        self.orderId = orderId
        self.managerId = managerId
    }
}
