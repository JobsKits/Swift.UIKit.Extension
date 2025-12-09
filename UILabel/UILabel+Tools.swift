//
//  UILabel+Tools.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
extension UILabel {
    /// 一次性设置文本样式 + 开启 Dynamic Type
    @available(iOS 10.0, *)
    @discardableResult
    func byDynamicTextStyle(_ style: UIFont.TextStyle) -> Self {
        self.font = .preferredFont(forTextStyle: style)
        self.adjustsFontForContentSizeCategory = true
        return self
    }
    /// 段落样式（对 attributedText 生效；若当前是纯文本会自动构造）
    @discardableResult
    func byParagraph(
        lineSpacing: CGFloat? = nil,
        paragraphSpacing: CGFloat? = nil,
        alignment: NSTextAlignment? = nil,
        lineHeightMultiple: CGFloat? = nil,
        hyphenationFactor: Float? = nil,
        kerning: Double? = nil
    ) -> Self {
        let raw = self.attributedText ?? {
            NSAttributedString(string: self.text ?? "", attributes: [
                .font: self.font as Any,
                .foregroundColor: self.textColor as Any
            ])
        }()

        let result = NSMutableAttributedString(attributedString: raw)
        let full = NSRange(location: 0, length: result.length)

        let p = (result.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle) ?? {
            return NSMutableParagraphStyle()
        }()

        if let v = lineSpacing { p.lineSpacing = v }
        if let v = paragraphSpacing { p.paragraphSpacing = v }
        if let v = alignment { p.alignment = v }
        if let v = lineHeightMultiple { p.lineHeightMultiple = v }
        if let v = hyphenationFactor { p.hyphenationFactor = v }

        result.addAttribute(.paragraphStyle, value: p, range: full)
        if let k = kerning { result.addAttribute(.kern, value: k, range: full) }

        self.attributedText = result
        return self
    }
    /// 尺寸测量
    func jobs_height(fittingWidth width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        return sizeThatFits(size).height
    }

    func jobs_width(fittingHeight height: CGFloat) -> CGFloat {
        let size = CGSize(width: .greatestFiniteMagnitude, height: height)
        return sizeThatFits(size).width
    }
    /// 轻量 Layer 阴影（UILabel 自带 shadowColor/Offset 太弱）
    @discardableResult
    func byLayerShadow(
        color: UIColor? = UIColor.black.withAlphaComponent(0.25),
        radius: CGFloat = 3,
        offset: CGSize = .init(width: 0, height: 2),
        opacity: Float = 1
    ) -> Self {
        layer.masksToBounds = false
        layer.shadowColor = color?.cgColor
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        return self
    }
    /// 显示样式（把旧枚举语义映射到具体行为）
    @discardableResult
    func makeLabelByShowingType(_ type: UILabelShowingType) -> Self {
        superview?.layoutIfNeeded()
        switch type {
        case .type01:
            /// 一行 + 省略号
            numberOfLines = 1
            lineBreakMode = .byTruncatingTail
        case .type02:
            /// 一行 + 裁剪（如需滚动，外层包 UIScrollView 再放 label）
            numberOfLines = 1
            lineBreakMode = .byClipping
            setContentCompressionResistancePriority(.required, for: .horizontal)
            setContentHuggingPriority(.defaultLow, for: .horizontal)
        case .type03:
            /// 一行，不定宽，定高，定字体 → 让宽度自适应
            numberOfLines = 1
            setContentCompressionResistancePriority(.required, for: .horizontal)
            setContentHuggingPriority(.required, for: .horizontal)
        case .type04:
            /// 一行，定宽定高，通过缩小字体完整显示
            numberOfLines = 1
            adjustsFontSizeToFitWidth = true
            minimumScaleFactor = 0.6
            lineBreakMode = .byClipping
        case .type05:
            /// 多行，定宽不定高，定字体
            numberOfLines = 0
            lineBreakMode = .byWordWrapping
        };return self
    }
}
