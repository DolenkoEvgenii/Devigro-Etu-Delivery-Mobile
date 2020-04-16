//
// Created by Евгений Доленко on 2019-05-02.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import Swinject
import UIKit

extension UIApplication {
    static func topInset() -> CGFloat {
        let window = UIApplication.shared.windows[safe: 0]
        return window?.safeAreaInsets.top ?? 0
    }

    static func bottomInset() -> CGFloat {
        let window = UIApplication.shared.windows[safe: 0]
        return window?.safeAreaInsets.bottom ?? 0
    }

    static var container: Container {
        return (UIApplication.shared.delegate as! AppDelegate).container
    }
}