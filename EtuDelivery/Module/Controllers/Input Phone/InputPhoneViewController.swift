//
//  EloGeoApp
//
//  Created by Евгений Доленко on 29/04/2019.
//  Copyright © 2019 Евгений Доленко. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import InputMask
import RxSwift

class InputPhoneViewController: BaseASViewController, InputPhoneViewProtocol {
    private let holderNode: HolderNode
    private let phoneInputDelegate: PhoneMaskDelegate

    private let configurator: InputPhoneConfiguratorProtocol
    var presenter: InputPhonePresenterProtocol!

    private var isButtonLocked = false

    init(configurator: InputPhoneConfiguratorProtocol) {
        self.configurator = configurator
        self.holderNode = HolderNode(actionButtonTitle: configurator.actionButtonTitle)
        self.phoneInputDelegate = PhoneMaskDelegate()

        phoneInputDelegate.primaryMaskFormat = "+7 ([000]) [000] [00] [00]"
        super.init(node: holderNode)

        phoneInputDelegate.resultClosure = { [weak self] isCompleted in
            guard let self = self else { return }
            self.holderNode.actionButtonNode.isEnabled = isCompleted && !self.isButtonLocked
        }
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

        holderNode.inputPhoneNode.textField.delegate = phoneInputDelegate

        holderNode.actionButtonNode.isEnabled = false
        holderNode.actionButtonNode.onTap { [weak self] _ in
            guard let self = self else { return }
            self.presenter.onPhoneEntered(phone: self.holderNode.inputPhoneNode.text)
        }
    }

    func disableActionButton(seconds: Int) {
        isButtonLocked = true
        self.holderNode.actionButtonNode.isEnabled = false

        let disposable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                .take(seconds)
                .map { seconds - $0 }
                .subscribe(onNext: { [weak self] value in
                    guard let self = self else { return }
                    let title = String(format: self.configurator.actionButtonCountDownTitle, value)
                    self.holderNode.actionButtonNode.setTitle(title, with: .systemFont(ofSize: 16), with: .white, for: .normal)
                }, onCompleted: { [weak self] in
                    guard let self = self else { return }
                    self.isButtonLocked = false
                    self.holderNode.actionButtonNode.isEnabled = self.holderNode.inputPhoneNode.text.count == 18
                    self.holderNode.actionButtonNode.setTitle(self.configurator.actionButtonTitle, with: .systemFont(ofSize: 16), with: .white, for: .normal)
                })

        disposeBag.insert(disposable)
    }

    private class HolderNode: ASDisplayNode {
        let topSpace: ASDisplayNode

        let logoNode: ASImageAuthHeightNode
        let inputPhoneNode: ASMainTextFieldNode
        let phoneLabelNode: ASTextNode
        let actionButtonNode: ASMainButtonNode

        init(actionButtonTitle: String) {
            topSpace = ASDisplayNode()

            logoNode = ASImageAuthHeightNode().then {
                $0.contentMode = .scaleAspectFit
                $0.clipsToBounds = true
                $0.image = UIImage(named: "logo")
            }

            phoneLabelNode = ASTextNode().then {
                $0.attributedText = NSAttributedString(string: "phone_number".localized(), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
            }

            inputPhoneNode = ASMainTextFieldNode().then {
                $0.textField.text = "+7"
                $0.textContainerInset = UIEdgeInsets(top: 13, left: 20, bottom: 21, right: 20)
            }

            actionButtonNode = ASMainButtonNode().then {
                $0.setTitle(actionButtonTitle, with: .systemFont(ofSize: 16), with: .white, for: .normal)
            }

            super.init()

            automaticallyManagesSubnodes = true
            backgroundColor = .white
        }

        override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            topSpace.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionAuto, height: ASDimensionMake("13%"))

            logoNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake("50%"), height: ASDimensionAuto)

            phoneLabelNode.style.spacingBefore = 40

            inputPhoneNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(250), height: ASDimensionAuto)

            actionButtonNode.style.minWidth = ASDimensionMake(100)
            actionButtonNode.style.width = ASDimensionAuto
            actionButtonNode.style.spacingBefore = 10

            let stackSpec = ASStackLayoutSpec(
                    direction: .vertical,
                    spacing: 10,
                    justifyContent: .start,
                    alignItems: .center,
                    children: [topSpace, logoNode, phoneLabelNode, inputPhoneNode, actionButtonNode])

            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: UIApplication.topInset(), left: 0, bottom: 0, right: 0), child: stackSpec)
        }
    }

    class PhoneMaskDelegate: MaskedTextFieldDelegate {
        var resultClosure: ((Bool) -> Void)?

        override func notifyOnMaskedTextChangedListeners(forTextField textField: UITextField, result: Mask.Result) {
            super.notifyOnMaskedTextChangedListeners(forTextField: textField, result: result)
            resultClosure?(result.complete)
        }
    }
}