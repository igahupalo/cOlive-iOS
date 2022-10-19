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
    private var minFieldHeight: CGFloat = 48
    private var fieldHeight: CGFloat = 48
    private var labelHeight: CGFloat = 30
    private let gap: CGFloat = 2
    private let buttonWidth: CGFloat = 32
    private let helpTextColor: UIColor = .black
    private let buttonColor: UIColor = .black
    private let messageFont = UIFont(name: "Now", size: 10)
    private let fieldWrapperView = UIView()
    private let messageLabel = UILabel()

    /// - Variables:
    ///     - hasError: flag saying is textfield carring an error message
    ///     - errorLabel: UILabel shown underneath the text field showing error message when one is given.
    ///     - errorImageView: UIImageView containing image of exclamation mark, displayed in text field's right view.

    private var hasError = false
    private var hasHelpText = false
    private var errorImageView: UIImageView?

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

    @IBInspectable var fieldBorderWidth: CGFloat = 1 {
        didSet { self.fieldWrapperView.layer.borderWidth = fieldBorderWidth }
    }

    @IBInspectable var fieldCornerRadius: CGFloat = 8 {
        didSet { self.fieldWrapperView.layer.cornerRadius = fieldCornerRadius }
    }

    @IBInspectable var fieldBorderColor: UIColor = UIColor(named: "mint-dark-opaque") ?? .black {
        didSet { self.fieldWrapperView.layer.borderColor = fieldBorderColor.cgColor }
    }
    @IBInspectable var fieldColor: UIColor = .white {
        didSet { self.fieldWrapperView.backgroundColor = fieldColor }
    }
    @IBInspectable var errorColor: UIColor = UIColor(named: "Red") ?? .red

    /// Calculated variable describing text rectangle's right inset.

    private var rightInset: CGFloat {
        let rightInset: CGFloat = rightPadding + gap + buttonWidth
        return rightInset
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.fieldHeight = frame.height - self.labelHeight
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override var intrinsicContentSize: CGSize {
        let width = super.intrinsicContentSize.width
        return CGSize(width: width, height: minFieldHeight + labelHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setup()
    }


    /// Overided function calculating and  returning right view's frame.

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: self.frame.width - rightPadding - buttonWidth, y: .zero, width: buttonWidth, height: self.fieldHeight)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let x = bounds.origin.x
        let y = bounds.origin.y
        let width = type != .none ? bounds.width - rightPadding - buttonWidth - gap : bounds.width
        let height = bounds.height - self.labelHeight
        let rect = super.textRect(forBounds: CGRect(x: x, y: y, width: width, height: height))
        return rect.offsetBy(dx: leftPadding, dy: .zero)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    /// Function sets up text field's elements and attaches handler removing error on beginning of text editing.

    private func setup() {
        self.floatingLabelYPadding = 5

        setupTrailingButton()
        setupMessageLabel()
        setupFieldWrapperView()

        self.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
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

    @objc func editingDidBegin() {
        removeMessages()
    }


    /// Function returns trailing button for text field of type .clear.

    private func clearButton() -> UIButton {
        let button = UIButton()
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

    private func setupFieldWrapperView() {

        let x = self.bounds.origin.x
        let y: CGFloat = .zero
        let width = self.bounds.width
        let height = self.bounds.height - self.labelHeight
        self.fieldWrapperView.frame = CGRect(x: x, y: y, width: width, height: height)
        self.fieldWrapperView.isUserInteractionEnabled = false
        self.styleFieldWrapperView()
        self.addSubview(self.fieldWrapperView)
        self.sendSubviewToBack(self.fieldWrapperView)
    }

    private func styleFieldWrapperView() {
        self.fieldWrapperView.layer.borderColor = self.fieldBorderColor.cgColor
        self.fieldWrapperView.layer.borderWidth = self.fieldBorderWidth
        self.fieldWrapperView.layer.cornerRadius = self.fieldCornerRadius
        self.fieldWrapperView.backgroundColor = fieldColor
    }

    /// Function sets up proper trailing button depending on text field's type.

    private func setupTrailingButton() {
        self.clearButtonMode = UITextField.ViewMode.never
        let button: UIButton?
        if type != .none {
            if rightView != nil { return }
            switch type {
            case .clear:
                button = clearButton()
            case .toggleSecureEntry:
                button = toggleSecureEntryButton()
            default:
                button = nil
            }
            button?.tintColor = buttonColor
            button?.frame = CGRect(x: .zero, y: .zero, width: buttonWidth, height: self.fieldHeight)
            button?.contentMode = .scaleAspectFit
            rightView = UIView()
            if button != nil {
                rightView!.addSubview(button!)
            }
        }
    }

    /// Function initializes label attached underneath the textfield, displaying error message.

    private func setupMessageLabel() {
        let x = leftPadding
        let y = self.fieldHeight
        let width = self.frame.width - leftPadding
        let height = self.labelHeight

        messageLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        messageLabel.font = messageFont
        self.addSubview(messageLabel)
    }

    func setHelpText(message: String) {
        if hasError {
            removeMessages()
        }
        messageLabel.text = message
        hasHelpText = true
    }

    /// Function used for setting a new error. It is responsible for hiding current trailing button, making visible error image and displaying given message. It triggers a wiggle animation on text field.

    func setError(message: String) {
        if hasHelpText {
            removeMessages()
        }

        if !hasError  {
            self.fieldWrapperView.layer.borderColor = self.errorColor.cgColor
            self.messageLabel.textColor = self.errorColor
        }

        messageLabel.text = message
        hasError = true
        self.wiggle()
    }

    /// Function used for the removal of an existing error, fired on every beginning of editing text of a text field with error flag.

    @objc func removeMessages() {
        messageLabel.text = ""
        if hasError {
            hasError = false
            self.fieldWrapperView.layer.borderColor = self.fieldBorderColor.cgColor
            self.fieldWrapperView.layer.borderWidth = self.fieldBorderWidth
            self.messageLabel.textColor = self.helpTextColor
        } else if hasHelpText {
            hasHelpText = false
        }
    }
}
