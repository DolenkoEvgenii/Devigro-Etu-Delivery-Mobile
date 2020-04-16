//
//  AuthModel.swift
//

import Foundation
import SwiftyUserDefaults

class AuthModel {
    static private let key = DefaultsKey<UserData?>("auth")

    final private class UserData: Codable, DefaultsSerializable {
        var authToken: String
        var token: String
        var name: String
        var phone: String
        var uid: String
        var timestamp: Int64

        init(authToken: String, token: String, name: String, phone: String, uid: String, timestamp: Int64) {
            self.authToken = authToken
            self.token = token
            self.name = name
            self.phone = phone
            self.uid = uid
            self.timestamp = timestamp
        }
    }

    private var data: UserData?

    init() {
        data = Defaults[AuthModel.key] ?? nil
    }

    var isAuthorized: Bool {
        return data != nil
    }

    var uid: String {
        return data?.uid ?? ""
    }

    var name: String {
        return data?.name ?? ""
    }

    var authToken: String {
        return data?.authToken ?? ""
    }

    var token: String {
        return data?.token ?? ""
    }

    var timestamp: Int64 {
        return data?.timestamp ?? 0
    }

    func update(loginResponse: LoginResponse) {
        let newData = UserData(
                authToken: loginResponse.token ?? "",
                token: "",
                name: "",
                phone: "",
                uid: "",
                timestamp: 0
        )

        Defaults[AuthModel.key] = newData
        data = newData
    }

    func update(profileResponse: GetProfileResponse) {
        let newData = UserData(
                authToken: authToken,
                token: token,
                name: profileResponse.fullName.fullName,
                phone: profileResponse.username,
                uid: profileResponse.id,
                timestamp: 0
        )

        Defaults[AuthModel.key] = newData
        data = newData
    }

    func clear() {
        data = nil
        Defaults[AuthModel.key] = nil
    }
}
