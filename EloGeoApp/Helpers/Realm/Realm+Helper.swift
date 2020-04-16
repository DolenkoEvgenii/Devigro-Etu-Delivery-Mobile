//
// Created by Евгений Доленко on 01.11.2019.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {
    func addAll(objectsArray: [Object], updatePolicy: UpdatePolicy = UpdatePolicy.modified) {
        for obj in objectsArray {
            add(obj, update: updatePolicy)
        }
    }
}