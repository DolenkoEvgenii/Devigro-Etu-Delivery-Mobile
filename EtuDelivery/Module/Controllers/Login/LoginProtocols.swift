//
// Created by Евгений Доленко on 2019-05-01.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation

protocol LoginViewProtocol: class, BaseViewInterface {

}

protocol LoginPresenterProtocol: class {
    func onLoginClick(username: String, password: String)
}