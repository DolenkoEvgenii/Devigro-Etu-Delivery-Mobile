//
// Created by Евгений Доленко on 2019-05-01.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import UIKit

class LoginPhoneConfirmConfigurator: ConfirmPhoneConfiguratorProtocol {
    var phone: String

    init(phone: String) { self.phone = phone }

    func configure(with viewController: ConfirmPhoneViewController) {
        viewController.presenter = LoginViaPhonePresenter(phone: phone, view: viewController)
    }
}