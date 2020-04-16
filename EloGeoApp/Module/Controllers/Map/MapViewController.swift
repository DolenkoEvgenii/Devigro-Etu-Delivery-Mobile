//
//  ViewController.swift
//  EloGeoApp
//
//  Created by Евгений Доленко on 29/04/2019.
//  Copyright © 2019 Евгений Доленко. All rights reserved.
//

import UIKit
import GoogleMaps
import FloatingPanel

class MapViewController: BaseViewController {
    @IBOutlet weak var mapContainer: UIView!

    let fpc = FloatingPanelController()

    var map: GMSMapView!

    var markerData: [GMSMarker: Order] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onOrdersUpdated(_:)), name: .ordersUpdated, object: nil)

        fpc.delegate = self
        drawMarkers()
    }

    @objc func onOrdersUpdated(_ notification: Notification) {
        drawMarkers()
    }

    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 1)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.map = mapView
        self.map.delegate = self
        view = mapView
    }

    private func drawMarkers() {
        markerData = [:]
        map.clear()
        let orders = OrderService.shared.activeOrders

        var firstMarker: GMSMarker? = nil
        for order in orders {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: order.from?.lat ?? 0, longitude: order.from?.lng ?? 0)
            marker.map = map
            markerData[marker] = order

            if (firstMarker == nil) {
                firstMarker = marker
            }
        }

        if let marker = firstMarker {
            self.map.animate(to: GMSCameraPosition(latitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 15))
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let order = markerData[marker] else {
            return true
        }

        let contentVC = AppStoryboard.orders.viewController(viewControllerClass: OrderInfoController.self)
        contentVC.order = order

        fpc.set(contentViewController: contentVC)
        fpc.isRemovalInteractionEnabled = true

        if (fpc.presentingViewController == nil) {
            present(fpc, animated: true)
        }

        map.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 9.0)
        return true
    }
}


extension MapViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return MyFloatingPanelLayout()
    }

    public class MyFloatingPanelLayout: FloatingPanelLayout {
        public init() {}

        public var initialPosition: FloatingPanelPosition {
            return .tip
        }
        public var supportedPositions: Set<FloatingPanelPosition> {
            return [.tip, .half]
        }

        public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
            switch position {
            case .tip: return 155
            case .half: return 388
            default: return nil
            }
        }
    }
}