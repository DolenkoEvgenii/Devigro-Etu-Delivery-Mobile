//
// Created by Евгений Доленко on 2019-05-01.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import Swinject
import RxSwift

class LoginPhoneInputPresenter: BasePresenter, InputPhonePresenterProtocol {
    weak var view: InputPhoneViewProtocol!
    let userService: UserServiceProtocol

    required init(view: InputPhoneViewProtocol) {
        self.view = view
        self.userService = UIApplication.container.resolve(UserServiceProtocol.self)!
    }

    func onPhoneEntered(phone: String) {
        sendSms(phone: phone)
    }

    private func sendSms(phone: String) {
        view.showProgress()

        let disposable = userService
                .requestPassword(phone: phone)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self]  response in
                    self?.view.disableActionButton(seconds: 30)
                    self?.view.hideProgress()
                    Router.showLoginConfirmPhoneVC(phone: phone)
                }, onError: { [weak self] error in
                    self?.view.showError(message: "phone_not_found".localized())
                })
        disposeBag.insert(disposable)
    }
}