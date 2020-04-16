//
// Created by Евгений Доленко on 2019-05-01.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

protocol InputPhoneViewProtocol: class, BaseViewInterface {
    func disableActionButton(seconds: Int)
}

protocol InputPhonePresenterProtocol: class {
    func onPhoneEntered(phone: String)
}

protocol InputPhoneConfiguratorProtocol: class {
    var actionButtonTitle: String { get set }
    var actionButtonCountDownTitle: String { get set }

    func configure(with viewController: InputPhoneViewController)
}