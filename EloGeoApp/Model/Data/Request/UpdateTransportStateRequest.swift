//
// Created by Евгений Доленко on 2019-05-03.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

class UpdateTransportStateRequest: Codable {
    let on_car: Int
    let on_truck: Int

    init(on_car: Int, on_truck: Int) {
        self.on_car = on_car
        self.on_truck = on_truck
    }
}