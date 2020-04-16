//
// Created by Евгений Доленко on 07.11.2019.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RealmSwift

public class LocationService: NSObject, CLLocationManagerDelegate {
    public static var sharedInstance = LocationService()
    let locationManager: CLLocationManager

    var timer: Timer?

    override init() {
        locationManager = CLLocationManager()

        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 3

        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }

        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false

        super.init()
        locationManager.delegate = self
        startTimer()
    }

    func startIfNeeded() {
        if (OrderService.shared.hasTrackingOrders) {
            startSendCoords()
        }
    }

    @objc func tick() {
        if (OrderService.shared.hasTrackingOrders) {
            startSendCoords()
        } else {
            stopSendCoords()
        }

        sendPendingCoords()
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("receive location")

        for order in OrderService.shared.trackingOrders {
            addTrackPoint(order: order, cords: location.coordinate)
        }
    }

    private func startSendCoords() {
        locationManager.startUpdatingLocation()
    }

    private func stopSendCoords() {
        locationManager.stopUpdatingLocation()
    }

    private func startTimer() {
        if timer == nil {
            let timer = Timer(timeInterval: 5.0,
                    target: self,
                    selector: #selector(tick),
                    userInfo: nil,
                    repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            timer.tolerance = 0.1

            self.timer = timer
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func addTrackPoint(order: Order, cords: CLLocationCoordinate2D) {
        if (order.status == .new || order.status == .completed) {
            return
        }

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let request = AddTrackPointData()
        request.order_id = order.id
        request.lat = cords.latitude
        request.lng = cords.longitude
        request.comment = "comment"
        request.status = order._status
        request.createdAt = dateFormatterGet.string(from: Date())

        let realm = try! Realm()
        try? realm.write {
            realm.add(request)

            let lastPoint = GeoPoint()
            lastPoint.lat = cords.latitude
            lastPoint.lng = cords.longitude
            order.lastPoint = lastPoint
        }
    }

    private func sendPendingCoords() {
        let realm = try! Realm()
        guard let firstPendingRequest = realm.objects(AddTrackPointData.self).sorted(byKeyPath: "createdAt", ascending: true).first else { return }

        _ = OrderService.shared
                .addTrackPoint(pointData: firstPendingRequest)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] response in
                    let realm = try! Realm()
                    try? realm.write {
                        realm.delete(firstPendingRequest)
                    }
                    self?.sendPendingCoords()
                }, onError: { error in

                })
    }
}