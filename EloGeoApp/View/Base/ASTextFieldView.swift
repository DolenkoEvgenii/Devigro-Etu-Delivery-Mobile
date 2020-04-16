//
// Created by Евгений Доленко on 2019-05-03.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import UIKit

class ASTextFieldView: UITextField {
    private var _textContainerInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

    var textContainerInset: UIEdgeInsets {
        get {
            return _textContainerInset
        }
        set(textContainerInset) {
            if textContainerInset != textContainerInset {
                _textContainerInset = textContainerInset
                setNeedsLayout()
            }
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: CGFloat(bounds.origin.x + _textContainerInset.left),
                y: CGFloat(bounds.origin.y + _textContainerInset.top),
                width: CGFloat(bounds.size.width - _textContainerInset.left - _textContainerInset.right),
                height: CGFloat(bounds.size.height - _textContainerInset.top - _textContainerInset.bottom))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}