//
// Created by Евгений Доленко on 15.06.2018.
//

import Foundation
import UIKit

class ExtendedButton: UIButton {
    var color: UIColor = UIColor.mainColor {
        didSet {
            styleView()
        }
    }
    var outlined = false {
        didSet {
            styleView()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }

    func initView() {
        var buttonText = self.title(for: .normal)
        if (buttonText != nil) {
            buttonText = buttonText!.localized().uppercased()
        }
        setTitleForAllStates(buttonText ?? "")
        setTitleColorForAllStates(.white)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        styleView()
    }

    func styleView() {
        if (outlined) {
            setTitleColor(color, for: .normal)
            layer.backgroundColor = UIColor.clear.cgColor

            layer.cornerRadius = frame.height / 2
            layer.borderColor = color.cgColor
            layer.borderWidth = 1
        } else {
            setTitleColor(.white, for: .normal)
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
            layer.cornerRadius = frame.height / 2

            layer.backgroundColor = color.cgColor
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if (isHighlighted) {
                let (red, green, blue) = color.rgbComponents
                let coef = 0.8
                layer.backgroundColor = UIColor(red: Int(Double(red) * coef), green: Int(Double(green) * coef), blue: Int(Double(blue) * coef)).cgColor
            } else {
                layer.backgroundColor = color.cgColor
            }
        }
    }
}
