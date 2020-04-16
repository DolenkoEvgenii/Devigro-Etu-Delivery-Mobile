//
//  EloGeoApp
//
//  Created by Евгений Доленко on 29/04/2019.
//  Copyright © 2019 Евгений Доленко. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Closures

class SelectAuthTypeViewController: BaseASViewController {
    let holderNode: HolderNode

    init() {
        holderNode = HolderNode()
        super.init(node: holderNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        holderNode.authViaPhoneNode.onTap { _ in
            Router.showLoginInputPhoneVC()
        }

        holderNode.authViaUsernameNode.onTap { _ in
            Router.showLoginViaUsernameVC()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    class HolderNode: ASDisplayNode {
        let topSpace: ASDisplayNode
        let logoNode: ASImageAuthHeightNode
        let authViaPhoneNode: ASMainButtonNode
        let authViaUsernameNode: ASMainButtonNode

        override init() {
            topSpace = ASDisplayNode()

            logoNode = ASImageAuthHeightNode().then {
                $0.contentMode = .scaleAspectFit
                $0.clipsToBounds = true
                $0.image = UIImage(named: "logo")
            }

            authViaPhoneNode = ASMainButtonNode().then {
                $0.setTitle("login_by_phone".localized(), with: .systemFont(ofSize: 16), with: .white, for: .normal)
            }

            authViaUsernameNode = ASMainButtonNode().then {
                $0.setTitle("login_by_username".localized(), with: .systemFont(ofSize: 16), with: .white, for: .normal)
            }

            super.init()

            automaticallyManagesSubnodes = true
            backgroundColor = .white
        }

        override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            topSpace.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionAuto, height: ASDimensionMake("13%"))

            authViaPhoneNode.style.preferredLayoutSize = ASLayoutSizeAuto
            authViaPhoneNode.style.spacingBefore = 50

            authViaUsernameNode.style.preferredLayoutSize = ASLayoutSizeAuto

            logoNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake("50%"), height: ASDimensionAuto)

            let stackSpec = ASStackLayoutSpec(
                    direction: .vertical,
                    spacing: 10,
                    justifyContent: .start,
                    alignItems: .center,
                    children: [topSpace, logoNode, authViaPhoneNode, authViaUsernameNode])

            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: UIApplication.topInset(), left: 0, bottom: 0, right: 0), child: stackSpec)
        }
    }
}