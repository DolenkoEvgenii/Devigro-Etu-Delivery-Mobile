//
// Created by Евгений Доленко on 2019-05-01.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import UIKit

class LoginViaUsernameConfigurator {
    func configure(with viewController: LoginViaUsernameViewController) {
        viewController.presenter = LoginViaUsernamePresenter(view: viewController)
    }
}