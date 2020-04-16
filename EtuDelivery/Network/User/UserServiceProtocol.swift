//
// Created by Евгений Доленко on 2019-05-04.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import RxSwift

protocol UserServiceProtocol {
    func loginViaUsername(username: String, password: String) -> Observable<LoginResponse>

    func loginViaPhone(phone: String, password: String) -> Observable<LoginResponse>

    func getProfile() -> Observable<GetProfileResponse>

    func updateTransportState(onCar: Bool, onTruck: Bool) -> Observable<SimpleResponse>

    func requestPassword(phone: String) -> Observable<GetPasswordResponse>
}
