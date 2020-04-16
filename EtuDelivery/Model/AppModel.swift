//
//  AppModel.swift
//

import Foundation
import SwiftyUserDefaults

class AppModel {
    // Текущие данные аутенфикации
    let auth = AuthModel()

    func clear(){
        auth.clear()
    }
}
