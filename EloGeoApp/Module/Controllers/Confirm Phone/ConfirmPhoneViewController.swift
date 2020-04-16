//
//  EloGeoApp
//
//  Created by Евгений Доленко on 29/04/2019.
//  Copyright © 2019 Евгений Доленко. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import CBPinEntryView
import RxSwift

class ConfirmPhoneViewController: BaseASViewController, ConfirmPhoneViewProtocol {
    private let holderNode: HolderNode

    private let configurator: ConfirmPhoneConfiguratorProtocol
    var presenter: ConfirmPhonePresenterProtocol!

    init(configurator: ConfirmPhoneConfiguratorProtocol) {
        self.configurator = configurator
        self.holderNode = HolderNode()
        super.init(node: holderNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(with: self)
        holderNode.inputCodeNode.view.becomeFirstResponder()

        holderNode.inputCodeView.delegate = self
    }

    func setCodeError() {
        holderNode.inputCodeView.setError(isError: true)
    }

    private class HolderNode: ASDisplayNode {
        let topSpace: ASDisplayNode

        let logoNode: ASImageAuthHeightNode
        let inputCodeNode: ASDisplayNode
        let codeLabelNode: ASTextNode

        var inputCodeView: CBPinEntryView {
            return inputCodeNode.view as! CBPinEntryView
        }

        override init() {
            topSpace = ASDisplayNode()

            logoNode = ASImageAuthHeightNode().then {
                $0.contentMode = .scaleAspectFit
                $0.clipsToBounds = true
                $0.image = UIImage(named: "logo")
            }

            codeLabelNode = ASTextNode().then {
                $0.attributedText = NSAttributedString(string: "code_from_sms".localized(), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
            }

            inputCodeNode = ASDisplayNode() {
                return CBPinEntryView().then {
                    $0.length = 4
                    $0.entryBackgroundColour = Color.white
                    $0.entryEditingBackgroundColour = Color.white

                    $0.entryBorderColour = .blue
                    $0.entryDefaultBorderColour = .mainColor

                    $0.entryBorderWidth = 2
                    $0.entryCornerRadius = 6
                    $0.entryFont = .systemFont(ofSize: 22)

                    $0.spacing = 30
                }
            }

            super.init()

            automaticallyManagesSubnodes = true
            backgroundColor = .white
        }

        override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            topSpace.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionAuto, height: ASDimensionMake("13%"))

            logoNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake("50%"), height: ASDimensionAuto)

            codeLabelNode.style.spacingBefore = 40

            inputCodeNode.style.spacingBefore = 10
            inputCodeNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake("60%"), height: ASDimensionMake(60))

            let stackSpec = ASStackLayoutSpec(
                    direction: .vertical,
                    spacing: 10,
                    justifyContent: .start,
                    alignItems: .center,
                    children: [topSpace, logoNode, codeLabelNode, inputCodeNode])

            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: UIApplication.topInset(), left: 0, bottom: 0, right: 0), child: stackSpec)
        }
    }
}

extension ConfirmPhoneViewController: CBPinEntryViewDelegate {
    public func entryCompleted(with entry: String?) {

    }

    func entryChanged(_ completed: Bool) {
        if (completed) {
            presenter.onSmsEntered(sms: holderNode.inputCodeView.getPinAsString())
        } else {
            holderNode.inputCodeView.setError(isError: false)
        }
    }
}