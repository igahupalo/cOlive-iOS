//
//  MaterialTextField.swift
//  cOlive
//
//  Created by Iga Hupalo on 08/10/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import Foundation
import UIKit
import JVFloatLabeledTextField

class MaterialTextField: JVFloatLabeledTextField {

    /// - Constants:
    ///     - padding: space between right edge of the trailing button and the end of the text field.
    ///     - gap: space between the right edge of the text rectangle and the left edge of the trailing button.
    ///     - width: width of the trailing button.
    ///     - errorColor: UIColor used to highlight text fields with eror flag.
    ///     - hasError: flag saying is textfield carring an error message

    private let leftPadding: CGFloat = 10
    private let rightPadding: CGFloat = 4
    private var fieldHeight: CGFloat = 48
    private let gap: CGFloat = 2
    private let width: CGFloat = 32
    private let errorColor: UIColor = UIColor(named: "red") ?? .red
    private let helpTextColor: UIColor = .black
    private let buttonColor: UIColor = .black
    private let messageFont = UIFont(name: "Now", size: 10)
    private var initialTintColor = UIColor(named: "MintDark") ?? .systemBlue

    /// - Variables:
    ///     - hasError: flag saying is textfield carring an error message
    ///     - errorLabel: UILabel shown underneath the text field showing error message when one is given.
    ///     - errorImageView: UIImageView containing image of exclamation mark, displayed in text field's right view.

    private var hasError = false
    private var hasHelpText = false
    private var errorImageView: UIImageView?

    /// Enumerator used for tag distribution and identification of views' elements.

    enum Tag: Int {
        case errorLabel = 1
        case helpTextLabel = 2
        case errorImageView = 3
        case trailingButton = 4
    }

    /// - Enumerator specifying types of trailing buttons:
    ///     - none: no trailing button
    ///     - clear: button appearing while editing, under condition of the text field's text not being empty, setting text to an empty string
    ///     - toggleSecureEntry: button toggling property isSecureTextEntry

    enum ButtonType: Int {
        case none, clear, toggleSecureEntry
    }

    /// Property describing current trailing button type.

    var type: ButtonType = .none

    /// Variable describing current trailing button type set in Attributes Inspector.

    @available(*, unavailable, message: "IB only")
    @IBInspectable var buttonType: Int {
        get {
            return self.type.rawValue
        }
        set(index) {
            self.type = ButtonType(rawValue: index) ?? ButtonType.none
        }
    }

    /// Calculated variable describing text rectangle's right inset.

    private var rightInset: CGFloat {
        let rightInset: CGFloat = rightPadding + gap + width
        return rightInset
    }

    /// Overided function calculating and  returning right view's frame.

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: self.frame.width - rightPadding - width, y: .zero, width: width, height: self.frame.height)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.offsetBy(dx: leftPadding, dy: self.text == "" ? .zero : 10)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    /// Function returns current proper rightViewMode for text field of type .clear. It makes the right view invisible if text field is empty, otherwise visible while editing.

    @objc func setClearRightViewMode() {
        let text = self.text ?? ""
        if text.count > 0 {
            rightViewMode = UITextField.ViewMode.whileEditing
        }
        else {
            rightViewMode = UITextField.ViewMode.never
        }
    }

    /// Function prevents the default behavior of clearing text of text field with secure text entry on every start of editing.

    override open func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        if !isSecureTextEntry { return true }
        if let currrentText = text {
            self.text = ""
            insertText(currrentText)
        }
        return true
    }

    /// Function returns trailing button for text field of type .clear.

    private func clearButton() -> UIButton {
        let button = UIButton()
        button.tag = Tag.trailingButton.rawValue
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        self.addTarget(self, action: #selector(setClearRightViewMode), for: .editingChanged)
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        setClearRightViewMode()
        return button
    }

    /// Function handiling an event of .clear text field's button tapped. It clears current text and hides button to prevent the display of the button which actions do nothing.

    @objc private func clearButtonTapped() {
        self.text = ""
        rightViewMode = UITextField.ViewMode.never
    }

    /// Function returns trailing button for text field of type .toggleSecureEntry. It toggles its image depending on current state of isSecureTextEntry.

    private func toggleSecureEntryButton() -> UIButton {
        let button = ToggleButton()
        button.tag = Tag.trailingButton.rawValue
        button.setImage(UIImage(systemName: "eye.slash"), for: isSecureTextEntry ? .normal : .selected)
        button.setImage(UIImage(systemName: "eye"), for: isSecureTextEntry ? .selected : .normal)
        button.addTarget(self, action: #selector(secureEntryButtonTapped), for: .touchUpInside)
        rightViewMode = UITextField.ViewMode.always
        return button
    }

    /// Function handiling an event of .toggleSecureEntry text field's button tapped. It toggles visibility of text.

    @objc private func secureEntryButtonTapped() {
        self.isSecureTextEntry.toggle()
        if let existingText = text, isSecureTextEntry {
            deleteBackward()
            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                replace(textRange, withText: existingText)
            }
        }
        if let existingSelectedTextRange = selectedTextRange {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }
    }

    /// Function sets up text field's elements and attaches handler removing error on beginning of text editing.

    private func setup() {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: self.fieldHeight)

        setupTrailingButton()
        setupErrorLabel()
        setupHelpTextLabel()
        setupErrorImage()

        self.addTarget(self, action: #selector(removeMessages), for: .editingDidBegin)
    }

    /// Function sets up proper trailing button depending on text field's type.

    private func setupTrailingButton() {
        self.clearButtonMode = UITextField.ViewMode.never
        if type != .none {
            if rightView != nil { return }
            let button: UIButton?
            switch type {
                case .clear:
                    button = clearButton()
                case .toggleSecureEntry:
                    button = toggleSecureEntryButton()
                default:
                    button = nil
            }
            button?.tintColor = buttonColor
            button?.frame = CGRect(x: .zero, y: .zero, width: width, height: self.frame.height)
            button?.contentMode = .scaleAspectFit
            rightView = UIView()
            if button != nil {
                rightView!.addSubview(button!)
            }
        }
    }

    /// Function initializes label attached underneath the textfield, displaying error message.

    private func messageLabel() -> UILabel {
        let messageLabel = UILabel()
        messageLabel.frame = CGRect(x: leftPadding, y: self.frame.height, width: self.frame.width, height: 30)
        messageLabel.font = messageFont
        messageLabel.isHidden = true
        return messageLabel
    }

    private func setupErrorLabel() {
        let errorLabel = messageLabel()
        errorLabel.textColor = errorColor
        errorLabel.tag = Tag.errorLabel.rawValue
        self.addSubview(errorLabel)
    }

    private func setupHelpTextLabel() {
        let helpTextLabel = messageLabel()
        helpTextLabel.textColor = helpTextColor
        helpTextLabel.tag = Tag.helpTextLabel.rawValue
        self.addSubview(helpTextLabel)
    }

    /// Function adjusts image view displaying exclamation mark symbol. Hidden image is attached to text fields with type other than .none, as it is imposible to create a subview of a nonexisting rightView.

    private func setupErrorImage() {
        errorImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: self.frame.height))
        errorImageView!.image = UIImage(systemName: "exclamationmark.circle")!
        errorImageView!.tintColor = errorColor
        errorImageView!.contentMode = UIView.ContentMode.scaleAspectFit
        errorImageView!.tag = Tag.errorImageView.rawValue
        errorImageView!.isHidden = true
        if let rightView = rightView {
            rightView.addSubview(errorImageView!)
        }
    }

    func setHelpText(message: String) {
        if hasError {
            removeMessages()
        }

        if !hasHelpText {
            if let helpTextLabel = self.viewWithTag(Tag.helpTextLabel.rawValue) as? UILabel{
                helpTextLabel.isHidden = false
            }
        }

        if let helpTextLabel = self.viewWithTag(Tag.helpTextLabel.rawValue) as? UILabel{
            helpTextLabel.text = message
        }

        hasHelpText = true
    }

    /// Function used for setting a new error. It is responsible for hiding current trailing button, making visible error image and displaying given message. It triggers a wiggle animation on text field.

    func setError(message: String) {
        if hasHelpText {
            removeMessages()
        }

        if !hasError  {
            rightViewMode = UITextField.ViewMode.always
        }

        if type == .none {
            rightView = errorImageView!
            rightView!.isHidden = false
        } else if !hasError {
            if let errorImageView = rightView?.viewWithTag(Tag.errorImageView.rawValue) {
                errorImageView.isHidden = false
            }
            if let trailingButton = rightView?.viewWithTag(Tag.trailingButton.rawValue) {
                trailingButton.isHidden = true
            }
            if let errorLabel = self.viewWithTag(Tag.errorLabel.rawValue) as? UILabel{
                errorLabel.isHidden = false
            }
        }

        self.tintColor = errorColor

        if let errorLabel = self.viewWithTag(Tag.errorLabel.rawValue) as? UILabel{
            errorLabel.text = message
        }

        hasError = true

        self.wiggle()
    }

    /// Function used for the removal of an existing error, fired on every beginning of editing text of a text field with error flag.

    @objc func removeMessages() {
        if hasError {
            hasError = false
            self.tintColor = initialTintColor

            if let errorImageView = rightView?.viewWithTag(Tag.errorImageView.rawValue) {
                errorImageView.isHidden = true
            }
            if let errorLabel = self.viewWithTag(Tag.errorLabel.rawValue) {
                (errorLabel as? UILabel)?.text = ""
                errorLabel.isHidden = true
            }
            if let trailingButton = rightView?.viewWithTag(Tag.trailingButton.rawValue) {
                trailingButton.isHidden = false
            }
            switch type {
                case .clear:
                    setClearRightViewMode()
                case .toggleSecureEntry:
                    rightViewMode = UITextField.ViewMode.always
                case .none:
                    rightView = nil
                    rightViewMode = UITextField.ViewMode.never
            }
        } else if hasHelpText {
            hasHelpText = false
            if let helpTextLabel = self.viewWithTag(Tag.helpTextLabel.rawValue) {
                (helpTextLabel as? UILabel)?.text = ""
                helpTextLabel.isHidden = true
            }
        }
    }

    func wiggle() {
        let wiggleAnim = CABasicAnimation(keyPath: "position")
        wiggleAnim.duration = 0.05
        wiggleAnim.repeatCount = 4
        wiggleAnim.autoreverses = true
        wiggleAnim.fromValue = CGPoint(x: self.center.x - 3.0, y: self.center.y)
        wiggleAnim.toValue = CGPoint(x: self.center.x + 3.0, y: self.center.y)
        layer.add(wiggleAnim, forKey: "position")
    }
}
