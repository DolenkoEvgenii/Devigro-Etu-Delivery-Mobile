//
//  EloGeoApp
//
//  Created by Евгений Доленко on 29/04/2019.
//  Copyright © 2019 Евгений Доленко. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import InputMask
import Closures

class LoginViaUsernameViewController: BaseASViewController, LoginViewProtocol {
    private let holderNode: HolderNode
    private let configurator = LoginViaUsernameConfigurator()
    var presenter: LoginPresenterProtocol!

    init() {
        holderNode = HolderNode()
        super.init(node: holderNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)

        self.navigationItem.leftBarButtonItem?.style = .plain
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(with: self)

        holderNode.loginButtonNode.isEnabled = false
        holderNode.loginButtonNode.onTap { [unowned self] _ in
            self.presenter.onLoginClick(username: self.holderNode.inputLoginNode.text, password: self.holderNode.inputPasswordNode.text)
        }

        holderNode.inputLoginNode.textField.delegate = self
        holderNode.inputPasswordNode.textField.delegate = self
    }

    private class HolderNode: ASDisplayNode {
        let topSpace: ASDisplayNode

        let logoNode: ASImageAuthHeightNode
        let inputLoginNode: ASMainTextFieldNode
        let inputPasswordNode: ASMainTextFieldNode
        let loginButtonNode: ASMainButtonNode

        override init() {
            topSpace = ASDisplayNode()

            logoNode = ASImageAuthHeightNode().then {
                $0.contentMode = .scaleAspectFit
                $0.clipsToBounds = true
                $0.image = UIImage(named: "logo")
            }

            inputLoginNode = ASMainTextFieldNode().then {
                $0.autocapitalizationType = .none
                $0.attributedPlaceholderText = NSAttributedString(string: "username".localized(), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
            }

            inputPasswordNode = ASMainTextFieldNode().then {
                $0.attributedPlaceholderText = NSAttributedString(string: "password".localized(), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
                $0.isSecureTextEntry = true
            }

            loginButtonNode = ASMainButtonNode().then {
                $0.setTitle("login".localized(), with: .systemFont(ofSize: 16), with: .white, for: .normal)
            }

            super.init()

            automaticallyManagesSubnodes = true
            backgroundColor = .white
        }

        override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            topSpace.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionAuto, height: ASDimensionMake("13%"))

            logoNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake("50%"), height: ASDimensionAuto)

            inputLoginNode.style.spacingBefore = 40
            inputLoginNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(250), height: ASDimensionAuto)
            inputPasswordNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(250), height: ASDimensionAuto)

            loginButtonNode.style.minWidth = ASDimensionMake(100)
            loginButtonNode.style.spacingBefore = 10

            let stackSpec = ASStackLayoutSpec(
                    direction: .vertical,
                    spacing: 10,
                    justifyContent: .start,
                    alignItems: .center,
                    children: [topSpace, logoNode, inputLoginNode, inputPasswordNode, loginButtonNode])

            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: UIApplication.topInset(), left: 0, bottom: 0, right: 0), child: stackSpec)
        }
    }
}

extension LoginViaUsernameViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isLoginEmpty = holderNode.inputLoginNode.text.isEmpty
        let isPasswordEmpty = holderNode.inputPasswordNode.text.isEmpty
        holderNode.loginButtonNode.isEnabled = !isLoginEmpty && !isPasswordEmpty
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}