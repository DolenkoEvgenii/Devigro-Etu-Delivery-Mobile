//
//  ViewController.swift
//  EloGeoApp
//
//  Created by Евгений Доленко on 29/04/2019.
//  Copyright © 2019 Евгений Доленко. All rights reserved.
//

import UIKit

class FinishedOrdersViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    private var orders: [Order] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "finished_orders".localized()
        let backItem = UIBarButtonItem(title: "cancel".localized(), style: .plain) { [unowned self] in
            self.dismiss(animated: true)
        }
        navigationItem.leftBarButtonItem = backItem

        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false

        updateData()
        NotificationCenter.default.addObserver(self, selector: #selector(onOrdersUpdated(_:)), name: .ordersUpdated, object: nil)
    }

    @objc func onOrdersUpdated(_ notification: Notification) {
        updateData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FinishedOrderCell.CELL_ID, for: indexPath) as! FinishedOrderCell
        cell.setupWithOrder(order: orders[indexPath.row])
        return cell
    }

    private func updateData() {
        orders = OrderService.shared.finishedOrders
        tableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
