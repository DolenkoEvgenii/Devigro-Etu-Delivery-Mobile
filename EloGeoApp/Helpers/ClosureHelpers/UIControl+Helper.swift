//
//  UIControl+Helper.swift
//  Haglar
//
//  Created by Nikishin Iliya on 06.01.2018.
//  Copyright © 2018 Nikishin Iliya. All rights reserved.
//

import UIKit

fileprivate class ClosureSleeve {
    let closure: () -> ()

    init(_ closure: @escaping () -> ()) {
        self.closure = closure
    }

    @objc func invoke() {
        closure()
    }
}

extension UIControl {
    func clearActions() {
        removeTarget(nil, action: nil, for: .allEvents)
    }

    func addAction(for controlEvents: Event, _ closure: @escaping () -> ()) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
