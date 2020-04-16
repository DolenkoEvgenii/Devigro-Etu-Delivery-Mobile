//
//  Created by Tom Baranes on 27/04/16.
//  Copyright © 2016 Tom Baranes. All rights reserved.
//

import UIKit

// MARK: - Navigation

extension UIViewController {

    public func removePreviousControllers(animated: Bool = false) {
        navigationController?.setViewControllers([self], animated: animated)
    }

    @objc
    var visibleController: UIViewController {
        return presentedViewController ?? self
    }
}
