import UIKit
import Foundation

class ExtendedLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }

    func initView() {
        text = text?.localized() ?? ""
    }
}
