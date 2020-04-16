//
// Created by Евгений Доленко on 2019-05-05.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import Swinject

class MainDIContainer {
    private init() {

    }

    static func get() -> Container {
        return Container() { container in
            container.register(HudProviderProtocol.self) { _ in
                MainHudProvider()
            }.inObjectScope(.container)

            container.register(UserServiceProtocol.self) { _ in
                UserService()
            }.inObjectScope(.transient)
        }
    }
}

