//
//  ViewController.swift
//  EloGeoApp
//
//  Created by Евгений Доленко on 29/04/2019.
//  Copyright © 2019 Евгений Доленко. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import PKHUD
import CoreLocation
import MapKit

class OrdersViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    lazy var refreshControl: UIRefreshControl = initRefreshControl()

    @IBOutlet weak var tableView: UITableView!

    private var orders: [Order] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        updateData()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.addSubview(self.refreshControl)

        NotificationCenter.default.addObserver(self, selector: #selector(onOrdersUpdated(_:)), name: .ordersUpdated, object: nil)
    }

    @objc func onOrdersUpdated(_ notification: Notification) {
        refreshControl.endRefreshing()
        updateData()
    }

    func initRefreshControl() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addAction(for: .valueChanged) { [unowned self] in
            OrderService.shared.updateOrders()
        }
        return refreshControl
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActualOrderCell.CELL_ID, for: indexPath) as! ActualOrderCell
        cell.setupWithOrder(order: orders[indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func openCoordinates(lat: Double, lng: Double) {
        let coordinate = CLLocationCoordinate2DMake(lat, lng)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
        mapItem.name = "Точка назначения"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    private func updateData() {
        orders = OrderService.shared.activeOrders
        tableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension OrdersViewController: ActualOrderDelegate {
    func providePresenter() -> UIViewController {
        return self
    }

    func onCordsClick(lat: Double, lng: Double) {
        openCoordinates(lat: lat, lng: lng)
    }

    func onStartTrackOrder(order: Order) {
        if (OrderService.shared.hasTransitOrders && OrderService.shared.transitOrders.first!.id != order.id) {
            showInfo(message: "only_1_active_order_permitted".localized())
        } else {
            updateOrderStatus(order: order, status: OrderStatus.on_road.rawValue)
        }
    }

    func onTechnicalStop(order: Order) {
        updateOrderStatus(order: order, status: OrderStatus.technical_stop.rawValue)
    }

    func onCompleteOrder(order: Order) {
        let realm = try! Realm()
        try? realm.write {
            order._status = OrderStatus.completed.rawValue
        }
        updateData()
        tableView.reloadData()

        _ = OrderService.shared.finishOrder(order: order)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { response in

                }, onError: { [weak self] error in
                    self?.onCompleteOrder(order: order)
                })
    }

    private func updateOrderStatus(order: Order, status: String, updateList: Bool = false) {
        let realm = try! Realm()
        try? realm.write {
            order._status = status
        }

        var date = Date()
        date.add(.second, value: 5)

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let createdAt = dateFormatterGet.string(from: date)

        let request = AddTrackPointData()
        request.order_id = order.id
        request.lat = order.lastPoint?.lat ?? order.from?.lat ?? 0
        request.lng = order.lastPoint?.lng ?? order.from?.lng ?? 0
        request.comment = "comment"
        request.status = order._status
        request.createdAt = createdAt

        try? realm.write {
            realm.add(request)
        }

        if (updateList) {
            updateData()
        }

        tableView.reloadData()
    }
}