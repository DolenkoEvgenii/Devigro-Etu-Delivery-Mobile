//
// Created by Евгений Доленко on 01.11.2019.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

enum OrderStatus: String {
    case new = "new"
    case on_road = "on_road"
    case technical_stop = "technical_stop"
    case completed = "completed"

    var status: String {
        return rawValue
    }

    var name: String {
        switch self {
        case .new:
            return "order_status_new".localized()
        case .on_road:
            return "order_status_in_transit".localized()
        case .technical_stop:
            return "order_status_technical_stop".localized()
        case .completed:
            return "order_status_completed".localized()
        }
    }
}