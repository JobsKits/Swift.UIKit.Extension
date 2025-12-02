//
//  UILabel.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
import Foundation
import ObjectiveC

#if canImport(JobsSwiftBaseTools)
import JobsSwiftBaseTools
#endif

#if canImport(JobsSwiftBaseDefines)
import JobsSwiftBaseDefines
#endif
// MARK: - UILabel 链式扩展
extension UILabel {
    @discardableResult
    func byJobsAttributedText(_ text: JobsText?) -> Self {
        guard let text else { return self }
        self.attributedText = text.asAttributed
        return self
    }
    @discardableResult
    func byJobsText(_ text: JobsText?) -> Self {
        guard let text else { return self }
        self.text = text.asString
        return self
    }
    @discardableResult
    func byText(_ text: String?) -> Self {
        self.text = text
        return self
    }
    @discardableResult
    func byTextColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }
    @discardableResult
    func byFont(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
    @discardableResult
    func byTextAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }
    @discardableResult
    func byNumberOfLines(_ lines: Int) -> Self {
        self.numberOfLines = lines
        return self
    }
    @discardableResult
    func byLineBreakMode(_ mode: NSLineBreakMode) -> Self {
        self.lineBreakMode = mode
        return self
    }
    @discardableResult
    func byBgCor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
    @discardableResult
    func byAttributedString(_ attributed: NSAttributedString?) -> Self {
        self.attributedText = attributed
        return self
    }
    @discardableResult
    func byNextText(_ str: String?) -> Self {
        self.text = (self.text ?? "") + (str ?? "")
        return self
    }
    @discardableResult
    func byNextAttributedText(_ attributed: NSAttributedString?) -> Self {
        if let current = self.attributedText {
            let result = NSMutableAttributedString(attributedString: current)
            if let attributed { result.append(attributed) }
            self.attributedText = result
        } else {
            self.attributedText = attributed
        };return self
    }
    @discardableResult
    func byHugging(_ priority: UILayoutPriority,
                   axis: NSLayoutConstraint.Axis = .horizontal) -> Self {
        setContentHuggingPriority(priority, for: axis)
        return self
    }
    /// 双轴便捷
    @discardableResult
    func byHugging(_ horizontal: UILayoutPriority, _ vertical: UILayoutPriority) -> Self {
        setContentHuggingPriority(horizontal, for: .horizontal)
        setContentHuggingPriority(vertical, for: .vertical)
        return self
    }

    @discardableResult
    func byCompressionResistance(_ priority: UILayoutPriority,
                                 axis: NSLayoutConstraint.Axis = .horizontal) -> Self {
        setContentCompressionResistancePriority(priority, for: axis)
        return self
    }
    /// 双轴便捷
    @discardableResult
    func byCompressionResistance(_ horizontal: UILayoutPriority, _ vertical: UILayoutPriority) -> Self {
        setContentCompressionResistancePriority(horizontal, for: .horizontal)
        setContentCompressionResistancePriority(vertical, for: .vertical)
        return self
    }

    // MARK: 背景图 → 平铺色
    @discardableResult
    func bgImage(_ image: UIImage?) -> Self {
        if let img = image {
            self.backgroundColor = UIColor(patternImage: img)
        };return self
    }
    // MARK: 显示样式（把旧枚举语义映射到具体行为）
    @discardableResult
    func makeLabelByShowingType(_ type: UILabelShowingType) -> Self {
        superview?.layoutIfNeeded()
        switch type {
        case .type01:
            // 一行 + 省略号
            numberOfLines = 1
            lineBreakMode = .byTruncatingTail
        case .type02:
            // 一行 + 裁剪（如需滚动，外层包 UIScrollView 再放 label）
            numberOfLines = 1
            lineBreakMode = .byClipping
            setContentCompressionResistancePriority(.required, for: .horizontal)
            setContentHuggingPriority(.defaultLow, for: .horizontal)
        case .type03:
            // 一行，不定宽，定高，定字体 → 让宽度自适应
            numberOfLines = 1
            setContentCompressionResistancePriority(.required, for: .horizontal)
            setContentHuggingPriority(.required, for: .horizontal)
        case .type04:
            // 一行，定宽定高，通过缩小字体完整显示
            numberOfLines = 1
            adjustsFontSizeToFitWidth = true
            minimumScaleFactor = 0.6
            lineBreakMode = .byClipping
        case .type05:
            // 多行，定宽不定高，定字体
            numberOfLines = 0
            lineBreakMode = .byWordWrapping
        };return self
    }
    // MARK: 方向变换（使用 CATextLayer，避免富文本/对齐丢失）
    @discardableResult
    func transformLayer(_ direction: TransformLayerDirectionType) -> Self {
        superview?.layoutIfNeeded()
        // 清理旧 layer（避免重复叠加）
        layer.sublayers?
            .filter { $0 is CATextLayer && $0.name == "JobsTextLayer" }
            .forEach { $0.removeFromSuperlayer() }

        let textLayer = CATextLayer()
        textLayer.name = "JobsTextLayer"
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = ._jobs_fromNSTextAlignment(textAlignment)
        textLayer.truncationMode = (lineBreakMode == .byTruncatingHead) ? .start :
                                   (lineBreakMode == .byTruncatingMiddle) ? .middle :
                                   (lineBreakMode == .byTruncatingTail) ? .end : .none
        textLayer.isWrapped = (numberOfLines == 0)

        if let attributed = attributedText {
            textLayer.string = attributed
        } else {
            textLayer.string = text ?? ""
            textLayer.foregroundColor = textColor.cgColor
            textLayer.font = font
            textLayer.fontSize = font.pointSize
        }
        textLayer.frame = bounds

        switch direction {
        case .up:
            break
        case .left:
            textLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            textLayer.transform = CATransform3DMakeRotation(-.pi/2, 0, 0, 1)
        case .down:
            textLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            textLayer.transform = CATransform3DMakeRotation(.pi, 0, 0, 1)
        case .right:
            textLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            textLayer.transform = CATransform3DMakeRotation(.pi/2, 0, 0, 1)
        }

        layer.addSublayer(textLayer)
        textColor = .clear // 只显示 layer 的文字
        return self
    }
    /// 一次性设置文本样式 + 开启 Dynamic Type
    @available(iOS 10.0, *)
    @discardableResult
    func byDynamicTextStyle(_ style: UIFont.TextStyle) -> Self {
        self.font = .preferredFont(forTextStyle: style)
        self.adjustsFontForContentSizeCategory = true
        return self
    }
    // ===== 新增：更多 by-DSL 补齐 =====
    // 高亮 / 交互 / 启用
    @discardableResult
    func byHighlightedTextColor(_ color: UIColor?) -> Self { self.highlightedTextColor = color; return self }

    @discardableResult
    func byIsHighlighted(_ v: Bool) -> Self { self.isHighlighted = v; return self }

    @discardableResult
    func byEnabled(_ v: Bool) -> Self { self.isEnabled = v; return self }

    // 文本压缩/缩放策略
    @discardableResult
    func byAdjustsFontSizeToFitWidth(_ v: Bool) -> Self { self.adjustsFontSizeToFitWidth = v; return self }

    @discardableResult
    func byBaselineAdjustment(_ v: UIBaselineAdjustment) -> Self { self.baselineAdjustment = v; return self }

    @discardableResult
    func byMinimumScaleFactor(_ v: CGFloat) -> Self { self.minimumScaleFactor = v; return self }

    @discardableResult
    func byAllowsDefaultTighteningForTruncation(_ v: Bool) -> Self { self.allowsDefaultTighteningForTruncation = v; return self }

    @available(iOS 14.0, *)
    @discardableResult
    func byLineBreakStrategy(_ s: NSParagraphStyle.LineBreakStrategy) -> Self { self.lineBreakStrategy = s; return self }

    // AutoLayout
    @discardableResult
    func byPreferredMaxLayoutWidth(_ w: CGFloat) -> Self { self.preferredMaxLayoutWidth = w; return self }

    // iOS 17
    @available(iOS 17.0, *)
    @discardableResult
    func byPreferredVibrancy(_ v: UILabelVibrancy) -> Self { self.preferredVibrancy = v; return self }

    @available(iOS 17.0, *)
    @discardableResult
    func byShowsExpansionTextWhenTruncated(_ v: Bool) -> Self { self.showsExpansionTextWhenTruncated = v; return self }

    // 段落样式（对 attributedText 生效；若当前是纯文本会自动构造）
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
    // 尺寸测量
    func jobs_height(fittingWidth width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        return sizeThatFits(size).height
    }

    func jobs_width(fittingHeight height: CGFloat) -> CGFloat {
        let size = CGSize(width: .greatestFiniteMagnitude, height: height)
        return sizeThatFits(size).width
    }
    // 轻量 Layer 阴影（UILabel 自带 shadowColor/Offset 太弱）
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
}

extension UILabel {
    /// 点语法：给 UILabel 加点击事件，返回自己
    @discardableResult
    func onTap(
        taps: Int = 1,
        touches: Int = 1,
        cancelsTouchesInView: Bool = true,
        isEnabled: Bool = true,
        name: String? = nil,
        _ handler: @escaping (UILabel) -> Void
    ) -> Self {
        isUserInteractionEnabled = true     // UIImageView 默认是 false，必须开
        let tapGR = UITapGestureRecognizer
            .byConfig { [weak self] gr in
                guard let self = self else { return }
                handler(self)               // 对外只暴露 UIImageView
            }
            .byTaps(taps)
            .byTouches(touches)
            .byCancelsTouchesInView(cancelsTouchesInView)
            .byEnabled(isEnabled)
            .byName(name)
        self.jobs_addGesture(tapGR)
        return self
    }
    /// 长按手势：返回 self，支持链式调用
    @discardableResult
    func onLongPress(
        minDuration: TimeInterval = 0.8,     // 最小按压时长
        movement: CGFloat = 12,              // 允许移动距离
        touches: Int = 1,                    // 手指数量
        cancelsTouchesInView: Bool = true,
        isEnabled: Bool = true,
        name: String? = nil,
        _ handler: @escaping (UILabel, UILongPressGestureRecognizer) -> Void
    ) -> Self {
        isUserInteractionEnabled = true
        self.jobs_addGesture(UILongPressGestureRecognizer
            .byConfig { [weak self] gr in
                guard let self = self,
                      let lp = gr as? UILongPressGestureRecognizer else { return }
                handler(self, lp)           // 对外只暴露 UILabel + LongPress
            }
            .byMinDuration(minDuration)
            .byMovement(movement)
            .byTouches(touches)
            .byCancelsTouchesInView(cancelsTouchesInView)
            .byEnabled(isEnabled)
            .byName(name))
        return self
    }
}
/// 一些功能性的
extension UILabel {
    // MARK: 设置富文本
    func richTextBy(_ runs: [JobsRichRun], paragraphStyle: NSMutableParagraphStyle? = nil)->Self {
        self.attributedText = JobsRichText.make(runs, paragraphStyle: paragraphStyle)
        self.isUserInteractionEnabled = false
        return self;
    }
    // MARK: - 检测点击位置是否在指定富文本范围内
    func didTapAttributedText(in range: NSRange, at: UITapGestureRecognizer) -> Bool {
        guard let attributedText = attributedText else { return false }
        // 1️⃣ 创建 NSTextStorage 管理文本
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        // 2️⃣ 计算点击位置
        let location = at.location(in: self)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let offset = CGPoint(
            x: (bounds.size.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (bounds.size.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        let locationInTextContainer = CGPoint(
            x: location.x - offset.x,
            y: location.y - offset.y
        )
        // 3️⃣ 获取点击的字符索引
        let index = layoutManager.characterIndex(for: locationInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(index, range)
    }
    // MARK: 给 UILabel 里的文字加 下划线，并且可以指定下划线的颜色。
    func underline(color: UIColor) {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                          value: NSUnderlineStyle.single.rawValue,
                                          range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSAttributedString.Key.underlineColor,
                                          value: color,
                                          range: NSRange(location: 0, length: attributedString.length))
            self.attributedText = attributedString
        }
    }
}
// MARK: - 文本内边距（不改类，关联对象 + 方法交换）
private var _jobsInsetsKey: UInt8 = 0
private var _jobsInsetsInstalledKey: UInt8 = 0
extension UILabel {
    /// 给 UILabel 增加 contentInsets 能力（无需自定义子类）
    var jobs_contentInsets: UIEdgeInsets {
        get { (objc_getAssociatedObject(self, &_jobsInsetsKey) as? NSValue)?.uiEdgeInsetsValue ?? .zero }
        set {
            objc_setAssociatedObject(self, &_jobsInsetsKey, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            _jobs_installInsetsSwizzleIfNeeded()
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }
    
    @discardableResult
    func byLabContentInsets(_ insets: UIEdgeInsets) -> Self {
        self.jobs_contentInsets = insets
        return self
    }
}

private extension UILabel {
    static let _once: Void = {
        let cls = UILabel.self
        // drawText(in:)
        _jobs_swizzle(cls, #selector(drawText(in:)), #selector(_jobs_drawText(in:)))
        // textRect(forBounds:limitedToNumberOfLines:)
        _jobs_swizzle(cls,
                      #selector(textRect(forBounds:limitedToNumberOfLines:)),
                      #selector(_jobs_textRect(forBounds:limitedToNumberOfLines:)))
        // intrinsicContentSize
        _jobs_swizzle(cls, #selector(getter: intrinsicContentSize), #selector(getter: _jobs_intrinsicContentSize))
    }()

    func _jobs_installInsetsSwizzleIfNeeded() {
        let installed = (objc_getAssociatedObject(UILabel.self, &_jobsInsetsInstalledKey) as? Bool) ?? false
        if !installed {
            _ = UILabel._once
            objc_setAssociatedObject(UILabel.self, &_jobsInsetsInstalledKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc func _jobs_drawText(in rect: CGRect) {
        let inset = jobs_contentInsets
        let r = rect.inset(by: inset)
        _jobs_drawText(in: r)
    }

    @objc func _jobs_textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let inset = jobs_contentInsets
        let b = bounds.inset(by: inset)
        let rect = _jobs_textRect(forBounds: b, limitedToNumberOfLines: numberOfLines)
        // 反向把 inset 加回去，保持 UILabel 外观尺寸一致
        return CGRect(x: rect.origin.x - inset.left,
                      y: rect.origin.y - inset.top,
                      width: rect.width + inset.left + inset.right,
                      height: rect.height + inset.top + inset.bottom)
    }

    @objc var _jobs_intrinsicContentSize: CGSize {
        let base = self._jobs_intrinsicContentSize
        let inset = jobs_contentInsets
        return CGSize(width: base.width + inset.left + inset.right,
                      height: base.height + inset.top + inset.bottom)
    }
}
// MARK: - 轻量方法交换
private func _jobs_swizzle(_ cls: AnyClass, _ orig: Selector, _ repl: Selector) {
    guard let m1 = class_getInstanceMethod(cls, orig),
          let m2 = class_getInstanceMethod(cls, repl) else { return }
    method_exchangeImplementations(m1, m2)
}
// MARK: - 对齐映射（CATextLayerAlignmentMode ← NSTextAlignment）
private extension CATextLayerAlignmentMode {
    static func _jobs_fromNSTextAlignment(_ a: NSTextAlignment) -> CATextLayerAlignmentMode {
        switch a {
        case .left: return .left
        case .right: return .right
        case .center: return .center
        case .justified: return .justified
        case .natural: return .natural
        @unknown default: return .natural
        }
    }
}
