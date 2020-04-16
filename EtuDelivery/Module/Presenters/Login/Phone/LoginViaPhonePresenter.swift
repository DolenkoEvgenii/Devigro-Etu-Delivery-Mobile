//
// Created by Евгений Доленко on 2019-05-01.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import Swinject
import RxSwift

class LoginViaPhonePresenter: BasePresenter, ConfirmPhonePresenterProtocol {
    weak var view: ConfirmPhoneViewProtocol!
    let userService: UserServiceProtocol
    let phone: String

    required init(phone: String, view: ConfirmPhoneViewProtocol) {
        self.phone = phone
        self.view = view
        self.userService = UIApplication.container.resolve(UserServiceProtocol.self)!
    }

    func onSmsEntered(sms: String) {
        login(sms: sms)
    }

    private func login(sms: String) {
        view.showProgress()

        let disposable = userService
                .loginViaPhone(phone: phone, password: sms)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak view]  response in
                    view?.showSuccess()
                    AppDelegate.model.auth.update(loginResponse: response)
                    Router.showMain()
                }, onError: { [weak view] error in
                    view?.hideProgress()
                    view?.setCodeError()
                })
        disposeBag.insert(disposable)
    }
}