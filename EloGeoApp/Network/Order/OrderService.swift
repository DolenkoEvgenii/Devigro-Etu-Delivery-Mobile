//
// Created by Евгений Доленко on 01.11.2019.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

extension Notification.Name {
    static let ordersUpdated = Notification.Name("ordersUpdated")
}

class OrderService: ApiService {
    static var shared: OrderService = {
        return OrderService()
    }()

    private override init() {}

    var allOrders: [Order] {
        let realm = try! Realm()
        return Array(realm.objects(Order.self))
    }

    var activeOrders: [Order] {
        allOrders.filter { $0.status != .completed }
    }

    var finishedOrders: [Order] { allOrders.filter { $0.status == .completed } }

    var transitOrders: [Order] { allOrders.filter { $0.status == .on_road || $0.status == .technical_stop } }

    var trackingOrders: [Order] { allOrders.filter { $0.status == .on_road } }

    var hasTransitOrders: Bool {
        return !transitOrders.isEmpty
    }

    var hasTrackingOrders: Bool {
        return !trackingOrders.isEmpty
    }

    func updateOrders() {
        let headers = ["Authorization": "Bearer " + AppDelegate.model.auth.authToken]
        get("mobile/order", queryParams: [:], headers: headers)
                .map { $0.0 }
                .flatMap { data -> Observable<[Order]> in
                    if let response: [Order] = self.parseJSON(data) {
                        return Observable.just(response)
                    } else {
                        return Observable.error(RuntimeError("unknown_error".localized()))
                    }
                }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self]  response in
                    do {
                        let realm = try Realm()
                        try realm.write {
                            realm.delete(realm.objects(Order.self))
                            realm.addAll(objectsArray: response, updatePolicy: .all)
                        }
                    } catch let error {
                        print(error)
                    }

                    self?.onOrdersUpdated()
                }, onError: { [weak self] error in
                    print(error.localizedDescription)
                })
    }

    /* func updateOrderDeliveryDate(order: Order, startDate: Date, endDate: Date) -> Observable<SimpleResponse> {
         let request = UpdateDeliveryDateRequest(order_id: order.id, interval_from: Int64(startDate.timeIntervalSince1970), interval_to: Int64(endDate.timeIntervalSince1970))
         let headers = ["Uid": AppDelegate.model.auth.uid, "Auth-key": AppDelegate.model.auth.authToken]
         return post("order/set-expected-interval", json: request, headers: headers)
                 .flatMap { data -> Observable<SimpleResponse> in
                     let jsonData = data.0

                     if let response: SimpleResponse = self.parseJSON(jsonData) {
                         if (response.success) {
                             return Observable.just(response)
                         } else {
                             return Observable.error(RuntimeError(response.error ?? ""))
                         }
                     } else {
                         return Observable.error(RuntimeError("error ".localized()))
                     }
                 }
     }

     func takeOrder(order: Order) -> Observable<SimpleResponse> {
         let headers = ["Uid": AppDelegate.model.auth.uid, "Auth-key": AppDelegate.model.auth.authToken]
         let params = ["order_id": String(order.id)]
         return get("order/take-order", queryParams: params, headers: headers)
                 .flatMap { data -> Observable<SimpleResponse> in
                     let jsonData = data.0

                     if let response: SimpleResponse = self.parseJSON(jsonData) {
                         if (response.success) {
                             return Observable.just(response)
                         } else {
                             return Observable.error(RuntimeError(response.error ?? ""))
                         }
                     } else {
                         return Observable.error(RuntimeError("error".localized()))
                     }
                 }
     }*/

    func finishOrder(order: Order) -> Observable<SimpleResponse> {
        let headers = ["Authorization": "Bearer " + AppDelegate.model.auth.authToken]
        let url = "order/\(order.id)/complete"

        return put(url, data: [:], headers: headers)
                .flatMap { data -> Observable<SimpleResponse> in
                    let jsonData = data.0

                    if data.1.statusCode == 200 {
                        return Observable.just(SimpleResponse())
                    } else {
                        if let response: SimpleResponse = self.parseJSON(jsonData) {
                            return Observable.error(RuntimeError(response.error ?? ""))
                        } else {
                            return Observable.error(RuntimeError("error".localized()))
                        }
                    }

                }
    }

    func addTrackPoint(pointData: AddTrackPointData) -> Observable<SimpleResponse> {
        let headers = ["Authorization": "Bearer " + AppDelegate.model.auth.authToken]
        let url = "order/\(pointData.order_id)/add-trackpoint"

        let point = GeoPoint()
        point.lng = pointData.lng
        point.lat = pointData.lat

        let request = AddTrackPointRequest(point: point, status: pointData.status, comment: pointData.comment, createdAt: pointData.createdAt)

        return post(url, json: request, headers: headers)
                .flatMap { data -> Observable<SimpleResponse> in
                    let jsonData = data.0

                    if data.1.statusCode == 200 || data.1.statusCode == 400 {
                        return Observable.just(SimpleResponse())
                    } else {
                        if let response: SimpleResponse = self.parseJSON(jsonData) {
                            return Observable.error(RuntimeError(response.error ?? ""))
                        } else {
                            return Observable.error(RuntimeError("error".localized()))
                        }
                    }

                }
    }

    private func onOrdersUpdated() {
        NotificationCenter.default.post(name: .ordersUpdated, object: nil)
    }
}
