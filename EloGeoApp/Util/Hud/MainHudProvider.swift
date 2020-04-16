//
// Created by Евгений Доленко on 2019-05-02.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import PKHUD
import UIKit

class MainHudProvider: HudProviderProtocol {
    func showInfo(message: String, completion: (() -> Void)?) {
        PKHUD.sharedHUD.dimsBackground = false
        PKHUD.sharedHUD.contentView = PKHUDTextView(text: message)
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false

        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 0.8) { _ in
            completion?()
        }
    }

    func showProgress() {
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        PKHUD.sharedHUD.contentView = PKHUDProgressView()

        PKHUD.sharedHUD.show()
    }

    func hideProgress() {
        PKHUD.sharedHUD.hide()
    }

    func showSuccess(message: String?, completion: (() -> Void)?) {
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        PKHUD.sharedHUD.contentView = PKHUDSuccessView(title: message)

        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 0.8) { _ in
            completion?()
        }
    }

    func showError(message: String?, completion: (() -> Void)?) {
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false

        let hudView = PKHUDErrorView(title: message)
        hudView.titleLabel.font = hudView.titleLabel.font.withSize(16)
        hudView.titleLabel.numberOfLines = 2
        PKHUD.sharedHUD.contentView = hudView

        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 0.8) { _ in
            completion?()
        }
    }
}
