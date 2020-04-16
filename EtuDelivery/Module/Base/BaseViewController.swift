//
//  BaseASViewController.swift
//
//  Created by Евгений Доленко on 29/04/2019.
//  Copyright © 2019 Евгений Доленко. All rights reserved.
//

import UIKit
import Swinject
import RxSwift

class BaseViewController: UIViewController, BaseViewInterface {
    let disposeBag = DisposeBag()
    let hudProvider = UIApplication.container.resolve(HudProviderProtocol.self)!

    func showInfo(message: String, completion: (() -> Void)?) {
        hudProvider.showInfo(message: message, completion: completion)
    }

    func showProgress() {
        hudProvider.showProgress()
    }

    func hideProgress() {
        hudProvider.hideProgress()
    }

    func showSuccess(message: String?, completion: (() -> Void)?) {
        hudProvider.showSuccess(message: message, completion: completion)
    }

    func showSuccess() {
        hudProvider.showSuccess(message: "successfully".localized(), completion: nil)
    }

    func showError(message: String?, completion: (() -> Void)?) {
        hudProvider.showError(message: message, completion: completion)
    }
}