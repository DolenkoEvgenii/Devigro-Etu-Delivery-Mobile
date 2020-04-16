//
// Created by Евгений Доленко on 14/09/2019.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    class var storyboardID: String {
        return "\(self)"
    }
}

enum AppStoryboard: String {
    case profile = "Profile"
    case map = "Map"
    case orders = "Orders"

    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }

    func viewController<T: UIViewController>(viewControllerClass: T.Type) -> T {
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        return instance.instantiateViewController(withIdentifier: storyboardID) as! T
    }
}
