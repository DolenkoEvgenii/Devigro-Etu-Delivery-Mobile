//
// Created by Евгений Доленко on 2019-05-01.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import UIKit

class Router: NSObject {
    static let `default` = Router()

    static var window = UIApplication.shared.delegate!.window!
    static var rootViewController = UIApplication.shared.delegate?.window??.rootViewController

    static var visibleController: UIViewController? {
        return rootViewController?.visibleController
    }

    static var navigationController: UINavigationController? {
        if let controller = visibleController as? UINavigationController {
            return controller
        }

        if visibleController is UISearchController {
            return visibleController?.parent?.navigationController
        }

        return visibleController?.navigationController
    }

    static func showMain() {
        let ordersVC = AppStoryboard.orders.viewController(viewControllerClass: OrdersViewController.self)
        let mapVC = AppStoryboard.map.viewController(viewControllerClass: MapViewController.self)
        let profileVC = AppStoryboard.profile.viewController(viewControllerClass: ProfileViewController.self)

        let orderItem = UITabBarItem()
        orderItem.title = "Orders"
        orderItem.image = UIImage(named: "orders")?.resizeImage(targetSize: CGSize(width: 22, height: 22))
        ordersVC.tabBarItem = orderItem

        let mapItem = UITabBarItem()
        mapItem.title = "Map"
        mapItem.image = UIImage(named: "map")?.resizeImage(targetSize: CGSize(width: 22, height: 22))
        mapVC.tabBarItem = mapItem

        let profileItem = UITabBarItem()
        profileItem.title = "Profile"
        profileItem.image = UIImage(named: "profile")?.resizeImage(targetSize: CGSize(width: 22, height: 22))
        profileVC.tabBarItem = profileItem

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [ordersVC, mapVC, profileVC]
        updateRootVC(vc: tabBarController, withNavController: false)
        OrderService.shared.updateOrders()
    }

    static func showAuth() {
        let vc = LoginViaUsernameViewController()
        updateRootVC(vc: vc)
    }

    static func showLoginInputPhoneVC() {
        let configurator = LoginPhoneInputConfigurator(actionButtonTitle: "login".localized(), actionButtonCountDownTitle: "send_again_in_d".localized())
        let vc = InputPhoneViewController(configurator: configurator)

        navigationController?.pushViewController(vc)
    }

    static func showLoginConfirmPhoneVC(phone: String) {
        let configurator = LoginPhoneConfirmConfigurator(phone: phone)
        let vc = ConfirmPhoneViewController(configurator: configurator)

        navigationController?.pushViewController(vc)
    }

    static func showLoginViaUsernameVC() {
        let vc = LoginViaUsernameViewController()
        navigationController?.pushViewController(vc)
    }

    static func updateRootVC(vc: UIViewController, withNavController: Bool = true) {
        let window = UIApplication.shared.delegate?.window
        let resVc = withNavController ? BaseNavigationController(rootViewController: vc) : vc

        window??.makeKey()
        window??.rootViewController = resVc
        window??.makeKeyAndVisible()
    }
}