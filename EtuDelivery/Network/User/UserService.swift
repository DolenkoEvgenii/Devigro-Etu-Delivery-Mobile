//
// Created by Евгений Доленко on 2019-05-04.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class UserService: ApiService, UserServiceProtocol {
    func loginViaUsername(username: String, password: String) -> Observable<LoginResponse> {
        return login(loginRequest: LoginRequest(username: username, password: password))
    }

    func loginViaPhone(phone: String, password: String) -> Observable<LoginResponse> {
        let resPhone = formatPhone(phone: phone)
        return login(loginRequest: LoginRequest(phone: resPhone, password: password))
    }

    private func login(loginRequest: LoginRequest) -> Observable<LoginResponse> {
        return post("auth/login", json: loginRequest)
                .flatMap { data -> Observable<LoginResponse> in
                    let jsonData = data.0
                    let httpResponse = data.1

                    if let response: LoginResponse = self.parseJSON(jsonData) {
                        if (response.token != nil) {
                            return Observable.just(response)
                        } else {
                            return Observable.error(RuntimeError("wrong_password".localized()))
                        }
                    } else {
                        return Observable.error(RuntimeError("wrong_password".localized()))
                    }
                }
    }

    func requestPassword(phone: String) -> Observable<GetPasswordResponse> {
        let resPhone = formatPhone(phone: phone)
        let headers = ["Device-label": "", "Device-id": ""]

        return post("site/get-password", json: GetPasswordRequest(phone: resPhone), headers: headers)
                .map { $0.0 }
                .flatMap { data -> Observable<GetPasswordResponse> in
                    if let response: GetPasswordResponse = self.parseJSON(data) {
                        if (response.success) {
                            return Observable.just(response)
                        } else {
                            return Observable.error(RuntimeError(response.error ?? ""))
                        }
                    } else {
                        return Observable.error(RuntimeError("unknown_error".localized()))
                    }
                }
    }

    func getProfile() -> Observable<GetProfileResponse> {
        let headers = ["Authorization": "Bearer " + AppDelegate.model.auth.authToken]

        return get("courier/self", queryParams: [:], headers: headers)
                .map { $0.0 }
                .flatMap { data -> Observable<GetProfileResponse> in
                    if let response: GetProfileResponse = self.parseJSON(data) {
                        return Observable.just(response)
                    } else {
                        return Observable.error(RuntimeError("cant_get_user_data".localized()))
                    }
                }
    }

    func updateTransportState(onCar: Bool, onTruck: Bool) -> Observable<SimpleResponse> {
        let headers = ["Authorization": "Bearer " + AppDelegate.model.auth.authToken]

        let request = UpdateTransportStateRequest(on_car: onCar ? 1 : 0, on_truck: onTruck ? 1 : 0)
        return post("profile/change-transport", json: request, headers: headers)
                .map { $0.0 }
                .flatMap { data -> Observable<SimpleResponse> in
                    /*if let response: SimpleResponse = self.parseJSON(data) {
                        if (response.success) {
                            return Observable.just(response)
                        } else {
                            return Observable.error(RuntimeError(response.error ?? ""))
                        }
                    } else {
                        return Observable.error(RuntimeError("unknown_error".localized()))
                    }
*/
                    return Observable.error(RuntimeError("unknown_error".localized()))
                }
    }

    private func formatPhone(phone: String) -> String {
        return phone
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .replacingOccurrences(of: "-", with: "")
    }
}
