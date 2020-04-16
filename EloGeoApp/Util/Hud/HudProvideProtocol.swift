//
// Created by Евгений Доленко on 2019-05-02.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

protocol HudProviderProtocol {
    func showInfo(message: String, completion: (() -> Void)?)

    func showProgress()
    func hideProgress()

    func showSuccess(message: String?, completion: (() -> Void)?)
    func showError(message: String?, completion: (() -> Void)?)
}

extension HudProviderProtocol {
    func showInfo(message: String) {
        showInfo(message: message, completion: nil)
    }


    func showSuccess() {
        showSuccess(message: nil, completion: nil)
    }

    func showSuccess(message: String) {
        showSuccess(message: message, completion: nil)
    }

    func showSuccess(completion: @escaping (() -> Void)) {
        showSuccess(message: nil, completion: completion)
    }

    func showError(message: String) {
        showError(message: message, completion: nil)
    }

    func showError() {
        showError(message: nil, completion: nil)
    }
}