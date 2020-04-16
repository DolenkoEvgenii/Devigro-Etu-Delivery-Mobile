//
// Created by Евгений Доленко on 2019-05-02.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit

class ASMainButtonNode: ASButtonNode {
    override init() {
        super.init()
        contentEdgeInsets = UIEdgeInsets(inset: 12)
        styleView()
    }

    override var isHighlighted: Bool {
        didSet {
            styleView()
        }
    }
    override var isEnabled: Bool {
        didSet {
            styleView()
        }
    }

    private func styleView() {
        cornerRadius = 8

        if (isEnabled) {
            backgroundColor = isHighlighted ? .mainColorDark : .mainColor
        } else {
            backgroundColor = .gray
        }
    }
}
