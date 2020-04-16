//
// Created by Евгений Доленко on 2019-05-03.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

class SendMessageRequest: Codable {
    let order_id: Int
    let chat_message: String?
    let manager_id: Int
    let attach: String?
    let attach_extension: String?

    init(order_id: Int, chat_message: String?, manager_id: Int, attach: String?, attach_extension: String?) {
        self.order_id = order_id
        self.chat_message = chat_message
        self.manager_id = manager_id
        self.attach = attach
        self.attach_extension = attach_extension
    }
}