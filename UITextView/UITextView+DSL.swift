//
//  UITextView+DSL.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/2/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

public extension UITextView {
    // MARK:  文本基础属性
    @discardableResult
    func byText(_ string: String?) -> Self {
        text = string
        return self
    }

    @discardableResult
    func byTextColor(_ color: UIColor) -> Self {
        textColor = color
        return self
    }

    @discardableResult
    func byFont(_ f: UIFont) -> Self {
        font = f
        return self
    }

    @discardableResult
    func byTextAlignment(_ alignment: NSTextAlignment) -> Self {
        textAlignment = alignment
        return self
    }

    @discardableResult
    func byAttributedText(_ attrText: NSAttributedString) -> Self {
        attributedText = attrText
        return self
    }

    @discardableResult
    func byTypingAttributes(_ attrs: [NSAttributedString.Key: Any]) -> Self {
        typingAttributes = attrs
        return self
    }
    // MARK: 可编辑与交互
    @discardableResult
    func byEditable(_ editable: Bool) -> Self {
        isEditable = editable
        return self
    }

    @discardableResult
    func bySelectable(_ selectable: Bool) -> Self {
        isSelectable = selectable
        return self
    }

    @discardableResult
    func byDataDetectorTypes(_ types: UIDataDetectorTypes) -> Self {
        dataDetectorTypes = types
        return self
    }

    @discardableResult
    func byAllowsEditingTextAttributes(_ allow: Bool) -> Self {
        allowsEditingTextAttributes = allow
        return self
    }
    // MARK: 输入相关
    @discardableResult
    func byKeyboardType(_ type: UIKeyboardType) -> Self {
        keyboardType = type
        return self
    }

    @discardableResult
    func byInputView(_ view: UIView?) -> Self {
        inputView = view
        return self
    }

    @discardableResult
    func byInputAccessoryView(_ view: UIView?) -> Self {
        inputAccessoryView = view
        return self
    }

    @discardableResult
    func byClearsOnInsertion(_ clear: Bool) -> Self {
        clearsOnInsertion = clear
        return self
    }
    // MARK: 富文本与链接样式
    @discardableResult
    func byLinkTextAttributes(_ attrs: [NSAttributedString.Key: Any]) -> Self {
        linkTextAttributes = attrs
        return self
    }

    @discardableResult
    @available(iOS 13.0, *)
    func byUsesStandardTextScaling(_ enable: Bool) -> Self {
        usesStandardTextScaling = enable
        return self
    }
    // MARK: 布局与内边距
    @discardableResult
    func byTextContainerInset(_ inset: UIEdgeInsets) -> Self {
        textContainerInset = inset
        return self
    }
    // MARK: 滚动与范围
    @discardableResult
    func byScrollToVisible(range: NSRange) -> Self {
        scrollRangeToVisible(range)
        return self
    }
    // MARK: 查找功能 (iOS 16+)
    @available(iOS 16.0, *)
    @discardableResult
    func byFindInteractionEnabled(_ enable: Bool) -> Self {
        isFindInteractionEnabled = enable
        return self
    }
    // MARK: 边框样式 (iOS 17+)
    @available(iOS 17.0, *)
    @discardableResult
    func byBorderStyle(_ style: UITextView.BorderStyle) -> Self {
        borderStyle = style
        return self
    }
    // MARK: 高亮显示 (iOS 18+)
    @available(iOS 18.0, *)
    @discardableResult
    func byTextHighlightAttributes(_ attrs: [NSAttributedString.Key: Any]) -> Self {
        textHighlightAttributes = attrs
        return self
    }
    // MARK:  Writing Tools (iOS 18+)
    @available(iOS 18.0, *)
    @discardableResult
    func byWritingToolsBehavior(_ behavior: UIWritingToolsBehavior) -> Self {
        writingToolsBehavior = behavior
        return self
    }

    @available(iOS 18.0, *)
    @discardableResult
    func byAllowedWritingToolsResultOptions(_ options: UIWritingToolsResultOptions) -> Self {
        var safe = options
        // ⚠️ iOS 18.0 / 18.1 暂不支持 table（部分机型连 list 也不行）
        safe.remove(.table)
        // safe.remove(.list) // 如果遇到崩溃，再打开这一行
        allowedWritingToolsResultOptions = safe
        return self
    }
    // MARK: 富文本格式配置 (iOS 18+)
    @available(iOS 18.0, *)
    @discardableResult
    func byTextFormattingConfiguration(_ config: UITextFormattingViewController.Configuration) -> Self {
        textFormattingConfiguration = config
        return self
    }
    // MARK: 代理设置
    @discardableResult
    func byDelegate(_ textViewDelegate: UITextViewDelegate?) -> Self {
        delegate = textViewDelegate
        return self
    }
    @available(iOS 10.0, *)
    @discardableResult
    func byDynamicTextStyle(_ style: UIFont.TextStyle) -> Self {
        self.font = .preferredFont(forTextStyle: style)
        self.adjustsFontForContentSizeCategory = true
        return self
    }
}

public extension UITextView {
    // MARK: 统一的圆角边框样式（跨 iOS 版本）
    @discardableResult
    func byRoundedBorder(
        color: UIColor = .systemGray4,
        width: CGFloat = 1,
        radius: CGFloat = 8,
        background: UIColor? = nil
    ) -> Self {
        layer.byBorderColor(color)
            .byBorderWidth(width)
            .byCornerRadius(radius)
            .byMasksToBounds(true)
        if let bg = background { backgroundColor = bg }
        return self
    }
    // MARK: 类似“bezel”的外观（简易版）
    @discardableResult
    func byBezelLike(
        radius: CGFloat = 8
    ) -> Self {
        layer.byBorderColor(.separator)
            .byBorderWidth(1)
            .byCornerRadius(radius)
            .byMasksToBounds(true)
        byBgColor(.secondarySystemBackground)
        return self
    }
}
