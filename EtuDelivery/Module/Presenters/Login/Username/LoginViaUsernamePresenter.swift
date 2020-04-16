//
// Created by Евгений Доленко on 2019-05-01.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import Swinject
import RxSwift
import RealmSwift

class LoginViaUsernamePresenter: BasePresenter, LoginPresenterProtocol {
    weak var view: LoginViewProtocol!
    let userService: UserServiceProtocol

    required init(view: LoginViewProtocol) {
        self.view = view
        self.userService = UIApplication.container.resolve(UserServiceProtocol.self)!
    }

    func onLoginClick(username: String, password: String) {
        login(username: username, password: password)
    }

    private func login(username: String, password: String) {
        view.showProgress()

        let disposable = userService
                .loginViaUsername(username: username, password: password)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self]  response in
                    let realm = try! Realm()
                    try? realm.write{
                        realm.deleteAll()
                    }

                    AppDelegate.model.auth.update(loginResponse: response)
                    self?.getUserInfo()
                }, onError: { [weak self] error in
                    self?.view.showError(message: error.message)
                })
        disposeBag.insert(disposable)
    }

    private func getUserInfo() {
        let disposable = userService
                .getProfile()
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self]  response in
                    self?.view.showSuccess()
                    AppDelegate.model.auth.update(profileResponse: response)
                    Router.showMain()
                }, onError: { [weak self] error in
                    AppDelegate.model.clear()
                    self?.view.showError(message: error.message)
                })
        disposeBag.insert(disposable)
    }
}