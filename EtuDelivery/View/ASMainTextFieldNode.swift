//
// Created by Евгений Доленко on 2019-05-02.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit

class ASMainTextFieldNode: ASTextFieldNode {
    override init() {
        super.init()
        styleView()
    }

    func styleView() {
        font = UIFont.systemFont(ofSize: 19)
        textColor = .black

        cornerRadius = 8
        textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        borderWidth = 1
        borderColor = UIColor.mainColor.cgColor
    }
}
