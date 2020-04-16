//
// Created by Евгений Доленко on 2019-05-03.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ASTextFieldNode: ASDisplayNode, UITextInputTraits {
    let textField: ASTextFieldView
    var textFieldNode: ASDisplayNode!

    override init() {
        textField = ASTextFieldView()
        super.init()

        textFieldNode = ASDisplayNode(viewBlock: {
            return self.textField
        })

        font = .systemFont(ofSize: 18)
        automaticallyManagesSubnodes = true
    }

    var textContainerInset: UIEdgeInsets {
        get {
            return textField.textContainerInset
        }
        set(textContainerInset) {
            textField.textContainerInset = textContainerInset
            style.height = ASDimensionMake(lineHeight + textField.textContainerInset.top + textField.textContainerInset.bottom)
            setNeedsLayout()
        }
    }

    var font: UIFont? {
        get {
            return textField.font
        }
        set(textContainerInset) {
            textField.font = font
        }
    }

    var textColor: UIColor? {
        get {
            return textField.textColor
        }
        set(textColor) {
            textField.textColor = textColor
        }
    }

    var text: String {
        get {
            return textField.text ?? ""
        }
        set(text) {
            textField.text = text
        }
    }

    var attributedText: NSAttributedString? {
        get {
            return textField.attributedText
        }
        set(attributedText) {
            textField.attributedText = attributedText
        }
    }

    var attributedPlaceholderText: NSAttributedString? {
        get {
            return textField.attributedPlaceholder
        }
        set(attributedText) {
            textField.attributedPlaceholder = attributedText
        }
    }

    var autocapitalizationType: UITextAutocapitalizationType {
        get {
            return textField.autocapitalizationType
        }
        set(autocapitalizationType) {
            textField.autocapitalizationType = autocapitalizationType
        }
    }

    var autocorrectionType: UITextAutocorrectionType {
        get {
            return textField.autocorrectionType
        }
        set(autocorrectionType) {
            textField.autocorrectionType = autocorrectionType
        }
    }

    var spellCheckingType: UITextSpellCheckingType {
        get {
            return textField.spellCheckingType
        }
        set(spellCheckingType) {
            textField.spellCheckingType = spellCheckingType
        }
    }

    var keyboardType: UIKeyboardType {
        get {
            return textField.keyboardType
        }
        set(keyboardType) {
            textField.keyboardType = keyboardType
        }
    }

    var keyboardAppearance: UIKeyboardAppearance {
        get {
            return textField.keyboardAppearance
        }
        set(keyboardAppearance) {
            textField.keyboardAppearance = keyboardAppearance
        }
    }

    func returnKeyType() -> UIReturnKeyType {
        return textField.returnKeyType
    }

    func setReturnKeyType(_ returnKeyType: UIReturnKeyType) {
        textField.returnKeyType = returnKeyType
    }

    var enablesReturnKeyAutomatically: Bool {
        get {
            return textField.enablesReturnKeyAutomatically
        }
        set(enablesReturnKeyAutomatically) {
            textField.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        }
    }

    var isSecureTextEntry: Bool {
        get {
            return textField.isSecureTextEntry
        }
        set(secureTextEntry) {
            textField.isSecureTextEntry = secureTextEntry
        }
    }

    var textContentType: UITextContentType {
        get {
            return textField.textContentType
        }
        set(textContentType) {
            textField.textContentType = textContentType
        }
    }

    override func becomeFirstResponder() -> Bool { return textField.becomeFirstResponder() }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let resH = max(lineHeight + textField.textContainerInset.top + textField.textContainerInset.bottom, constrainedSize.min.height)

        var resSize = ASLayoutSize()
        resSize.width = ASDimensionMake(constrainedSize.min.width)
        resSize.height = ASDimensionMake(resH)

        textFieldNode.style.preferredLayoutSize = resSize
        let spec = ASAbsoluteLayoutSpec(children: [textFieldNode])
        return spec
    }

    var lineHeight: CGFloat {
        if font != nil {
            return font!.lineHeight
        }
        return UIFont.systemFont(ofSize: 17.0).lineHeight
    }
}