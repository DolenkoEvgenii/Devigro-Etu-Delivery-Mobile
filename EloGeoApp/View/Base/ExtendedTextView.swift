import UIKit
import Foundation

class ExtendedTextField: UITextField {
    private var marginHorizont: Int = 31
    private var marginVert: Int = -1

    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }

    func initView() {
        let color = UIColor.darkGray
        var placeholderText = placeholder
        placeholderText = placeholderText?.localized()
        self.attributedPlaceholder = NSAttributedString(string: placeholderText ?? "", attributes: [NSAttributedString.Key.foregroundColor: color])

        textColor = UIColor(hexString: "#8B4646")
        styleView()
    }

    func styleView() {
        layer.borderWidth = 1
        layer.borderColor = UIColor(hexString: "#8B8B8B").cgColor
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = 5

        alpha = 0.9
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let inset = CGRect(x: bounds.origin.x + CGFloat(marginHorizont), y: bounds.origin.y - CGFloat(marginVert),
                width: bounds.size.width - CGFloat(marginHorizont), height: bounds.size.height + CGFloat(marginVert))
        return inset
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let inset = CGRect(x: bounds.origin.x + CGFloat(marginHorizont), y: bounds.origin.y - CGFloat(marginVert),
                width: bounds.size.width - CGFloat(marginHorizont), height: bounds.size.height + CGFloat(marginVert))
        return inset
    }

    func setMarginHorizontal(_ margin: Int) {
        marginHorizont = margin
    }

    func setMarginVertical(_ margin: Int) {
        marginVert = margin
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
