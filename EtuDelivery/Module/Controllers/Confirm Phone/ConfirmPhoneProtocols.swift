//
// Created by Евгений Доленко on 2019-05-01.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

protocol ConfirmPhoneViewProtocol: class, BaseViewInterface {
    func setCodeError()
}

protocol ConfirmPhonePresenterProtocol: class {
    func onSmsEntered(sms: String)
}

protocol ConfirmPhoneConfiguratorProtocol: class {
    var phone: String { get set }

    func configure(with viewController: ConfirmPhoneViewController)
}