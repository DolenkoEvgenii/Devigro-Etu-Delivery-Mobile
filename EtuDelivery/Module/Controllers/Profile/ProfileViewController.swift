//
//  ViewController.swift
//  EloGeoApp
//
//  Created by Евгений Доленко on 29/04/2019.
//  Copyright © 2019 Евгений Доленко. All rights reserved.
//

import UIKit
import RxSwift
import BEMCheckBox

class ProfileViewController: BaseViewController {
    @IBOutlet weak var courierNameLabel: UILabel!
    @IBOutlet weak var profileStatusLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var passportDataLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var finishedOrdersLabel: UILabel!

    @IBOutlet weak var carCheckbox: BEMCheckBox!
    @IBOutlet weak var truckCheckbox: BEMCheckBox!

    @IBOutlet weak var logoutButton: ExtendedButton!

    let userService = UIApplication.container.resolve(UserServiceProtocol.self)!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateProfile()

        carCheckbox.boxType = .square
        truckCheckbox.boxType = .square
        logoutButton.color = UIColor(hexString: "#f54029")

        NotificationCenter.default.addObserver(self, selector: #selector(onOrdersUpdated(_:)), name: .ordersUpdated, object: nil)
        OrderService.shared.updateOrders()
    }

    @objc func onOrdersUpdated(_ notification: Notification) {
        finishedOrdersLabel.text = "number_of_completed_orders".localized() + ": " + String(OrderService.shared.finishedOrders.count)
    }

    @IBAction func onUpdateTransportClick(_ sender: Any) {
        saveTransportState(onCar: carCheckbox.on, onTruck: truckCheckbox.on)
    }

    @IBAction func onUpdateProfileClick(_ sender: Any) {
        updateProfile()
    }

    @IBAction func onFinishedOrdersClick(_ sender: Any) {
        let vc = AppStoryboard.orders.viewController(viewControllerClass: FinishedOrdersViewController.self)
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .fullScreen

        present(navVc, animated: true)
    }

    @IBAction func onLogoutClick(_ sender: Any) {
        AppDelegate.model.clear()
        Router.showAuth()
    }

    private func updateProfile() {
        showProgress()

        let disposable = userService
                .getProfile()
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self]  response in
                    self?.hideProgress()
                    self?.showProfileInfo(profile: response)
                }, onError: { [weak self] error in
                    self?.hideProgress()
                })
        disposeBag.insert(disposable)
    }

    private func saveTransportState(onCar: Bool, onTruck: Bool) {
        showProgress()

        let disposable = userService
                .updateTransportState(onCar: onCar, onTruck: onTruck)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self]  response in
                    self?.showSuccess()
                }, onError: { [weak self] error in
                    self?.showError(message: error.message, completion: nil)
                })
        disposeBag.insert(disposable)
    }

    private func showProfileInfo(profile: GetProfileResponse) {
        courierNameLabel.text = "courier_name".localized() + ": " + profile.fullName.fullName
        profileStatusLabel.text = "profile_status".localized() + ": " + "неизвестно"
        companyNameLabel.text = "company".localized() + ": " + (profile.company?.name ?? "")
        passportDataLabel.text = "email".localized() + ": " + (profile.email ?? "")
        phoneNumberLabel.text = "username".localized() + ": " + profile.phone
        finishedOrdersLabel.text = "number_of_completed_orders".localized() + ": " + String(OrderService.shared.finishedOrders.count)

        //carCheckbox.on = profile.onCar == 1
        //truckCheckbox.on = profile.onTruck == 1
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}