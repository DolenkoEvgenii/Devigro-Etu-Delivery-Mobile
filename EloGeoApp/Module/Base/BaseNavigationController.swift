//
// Created by Евгений Доленко on 27/12/2018.
//

import UIKit
import Foundation

class BaseNavigationController: UINavigationController, UINavigationBarDelegate {
    private var keyboardIsShown = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    private func hideKeyboard() {
        view.endEditing(true)
    }

    @objc func keyboardWillAppear() {
        keyboardIsShown = true
    }

    @objc func keyboardWillDisappear() {
        keyboardIsShown = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if (keyboardIsShown) {
            hideKeyboard()
            return false
        } else {
            popViewController(animated: true)
            return false
        }
    }
}