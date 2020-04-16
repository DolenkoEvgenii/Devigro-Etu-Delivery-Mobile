//
// Created by Евгений Доленко on 07.11.2019.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import UIKit
import FloatingPanel
import CoreLocation
import MapKit

class OrderInfoController: BaseViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startAddressLabel: UILabel!
    @IBOutlet weak var endAddressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!

    var order: Order!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = order.status.name
        startAddressLabel.text = order.from?.address
        endAddressLabel.text = order.to?.address

        let coordinateA = CLLocation(latitude: order.from?.lat ?? 0.0, longitude: order.from?.lng ?? 0.0)
        let coordinateB = CLLocation(latitude: order.to?.lat ?? 0.0, longitude: order.to?.lng ?? 0.0)
        let distanceInMeters = Int(coordinateA.distance(from: coordinateB))

        distanceLabel.text = "distance".localized() + ": \(distanceInMeters) м."
        costLabel.text = "cost".localized() + ": \(order.cost) р."
    }

    @IBAction func startPointClick(_ sender: Any) {
        openCoordinates(lat: order.from?.lat ?? 0, lng: order.from?.lng ?? 0)
    }

    @IBAction func endPointClick(_ sender: Any) {
        openCoordinates(lat: order.to?.lat ?? 0, lng: order.to?.lng ?? 0)
    }

    private func openCoordinates(lat: Double, lng: Double) {
        let coordinate = CLLocationCoordinate2DMake(lat, lng)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
        mapItem.name = "Точка назначения"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}
