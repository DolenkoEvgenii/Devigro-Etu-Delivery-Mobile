//
// Created by Евгений Доленко on 2019-05-01.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import UIKit

class LoginPhoneInputConfigurator: InputPhoneConfiguratorProtocol {
    var actionButtonTitle: String
    var actionButtonCountDownTitle: String

    init(actionButtonTitle: String, actionButtonCountDownTitle: String) {
        self.actionButtonTitle = actionButtonTitle
        self.actionButtonCountDownTitle = actionButtonCountDownTitle
    }

    func configure(with viewController: InputPhoneViewController) {
        viewController.presenter = LoginPhoneInputPresenter(view: viewController)
    }
}