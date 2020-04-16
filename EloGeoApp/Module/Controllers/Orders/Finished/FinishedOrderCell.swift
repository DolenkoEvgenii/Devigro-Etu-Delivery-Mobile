//
// Created by Евгений Доленко on 01.11.2019.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class FinishedOrderCell: UITableViewCell {
    static let CELL_ID = "orderCell"
    static let CELL_HEIGHT: CGFloat = 66

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startAddressLabel: UILabel!
    @IBOutlet weak var endAddressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    func setupWithOrder(order: Order) {
        titleLabel.text = order.status.name
        startAddressLabel.text = order.from?.address
        endAddressLabel.text = order.to?.address

        let coordinateA = CLLocation(latitude: order.from?.lat ?? 0.0, longitude: order.from?.lng ?? 0.0)
        let coordinateB = CLLocation(latitude: order.to?.lat ?? 0.0, longitude: order.to?.lng ?? 0.0)
        let distanceInMeters = Int(coordinateA.distance(from: coordinateB))

        distanceLabel.text = "distance".localized() + ": \(distanceInMeters) м."
        costLabel.text = "cost".localized() + ": \(order.cost) р."
    }
}
