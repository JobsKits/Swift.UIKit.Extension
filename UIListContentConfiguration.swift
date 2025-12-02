//
//  UIListContentConfiguration.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/11/25.
//

import UIKit
// ================================== 示例 ==================================
// cell.byListConfig {
//     $0.byText("主标题")
//       .bySecondaryText("副标题")
//       .byImage(systemName: "tray")
//       .byPreferredSymbol(pointSize: 18, weight: .semibold)
//       .byTintColor(.systemBlue)
//       .byImageCornerRadius(6)
//       .byImageMaximumSize(CGSize(width: 28, height: 28))
//       .byTextFont(.preferredFont(forTextStyle: .body))
//       .byTextColor(.label)
//       .bySecondaryFont(.preferredFont(forTextStyle: .subheadline))
//       .bySecondaryColor(.secondaryLabel)
//       .byTextLines(1)
//       .bySecondaryLines(1)
//       .byPrefersSideBySideTextAndSecondaryText(true)
//       .byImageToTextPadding(8)
//       .byPrimarySecondaryHorizontalPadding(8)
//       .byDirectionalLayoutMargins(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
// }
// ================================== 基础扩展 · 总体 ==================================
@available(iOS 14.0, tvOS 14.0, *)
@available(watchOS, unavailable)
public extension UIListContentConfiguration {
    // MARK: - 小工具
    private func jobs_mutating(_ body: (inout UIListContentConfiguration) -> Void) -> UIListContentConfiguration {
        var copy = self
        body(&copy)
        return copy
    }
    // ================================== 便捷构造 ==================================
    /// `.cell()` / `.subtitleCell()` / `.valueCell()` 等系统模板的语义化便捷入口
    static func jobsCell(text: String? = nil,
                         secondary: String? = nil,
                         image: UIImage? = nil) -> UIListContentConfiguration {
        var c = UIListContentConfiguration.cell()
        c.text = text
        c.secondaryText = secondary
        c.image = image
        return c
    }

    static func jobsSubtitleCell(text: String? = nil,
                                 secondary: String? = nil,
                                 image: UIImage? = nil) -> UIListContentConfiguration {
        var c = UIListContentConfiguration.subtitleCell()
        c.text = text
        c.secondaryText = secondary
        c.image = image
        return c
    }

    static func jobsValueCell(text: String? = nil,
                              secondary: String? = nil,
                              image: UIImage? = nil) -> UIListContentConfiguration {
        var c = UIListContentConfiguration.valueCell()
        c.text = text
        c.secondaryText = secondary
        c.image = image
        return c
    }

    @available(iOS 18.0, tvOS 18.0, *)
    static func jobsHeader(text: String? = nil,
                           secondary: String? = nil) -> UIListContentConfiguration {
        var c = UIListContentConfiguration.header()
        c.text = text
        c.secondaryText = secondary
        return c
    }

    @available(iOS 18.0, tvOS 18.0, *)
    static func jobsFooter(text: String? = nil,
                           secondary: String? = nil) -> UIListContentConfiguration {
        var c = UIListContentConfiguration.footer()
        c.text = text
        c.secondaryText = secondary
        return c
    }

    // ================================== 核心字段 ==================================
    @discardableResult
    func byText(_ value: String?) -> Self {
        jobs_mutating { $0.text = value }
    }

    @discardableResult
    func byAttributedText(_ value: NSAttributedString?) -> Self {
        jobs_mutating { $0.attributedText = value }
    }

    @discardableResult
    func bySecondaryText(_ value: String?) -> Self {
        jobs_mutating { $0.secondaryText = value }
    }

    @discardableResult
    func bySecondaryAttributedText(_ value: NSAttributedString?) -> Self {
        jobs_mutating { $0.secondaryAttributedText = value }
    }

    @discardableResult
    func byImage(_ value: UIImage?) -> Self {
        jobs_mutating { $0.image = value }
    }

    /// 便捷：直接使用 SF Symbol 名称
    @discardableResult
    func byImage(systemName: String) -> Self {
        jobs_mutating { $0.image = UIImage(systemName: systemName) }
    }

    // ================================== 布局/边距/排布 ==================================
    @discardableResult
    func byAxesPreservingSuperviewLayoutMargins(_ axes: UIAxis) -> Self {
        jobs_mutating { $0.axesPreservingSuperviewLayoutMargins = axes }
    }

    @discardableResult
    func byDirectionalLayoutMargins(_ edges: NSDirectionalEdgeInsets) -> Self {
        jobs_mutating { $0.directionalLayoutMargins = edges }
    }

    /// 便捷：用 `UIEdgeInsets` 适配成 Directional
    @discardableResult
    func byLayoutMargins(_ edges: UIEdgeInsets) -> Self {
        jobs_mutating {
            $0.directionalLayoutMargins = .init(top: edges.top, leading: edges.left, bottom: edges.bottom, trailing: edges.right)
        }
    }

    @discardableResult
    func byPrefersSideBySideTextAndSecondaryText(_ flag: Bool) -> Self {
        jobs_mutating { $0.prefersSideBySideTextAndSecondaryText = flag }
    }

    @discardableResult
    func byImageToTextPadding(_ v: CGFloat) -> Self {
        jobs_mutating { $0.imageToTextPadding = v }
    }

    @discardableResult
    func byPrimarySecondaryHorizontalPadding(_ v: CGFloat) -> Self {
        jobs_mutating { $0.textToSecondaryTextHorizontalPadding = v }
    }

    @discardableResult
    func byPrimarySecondaryVerticalPadding(_ v: CGFloat) -> Self {
        jobs_mutating { $0.textToSecondaryTextVerticalPadding = v }
    }

    @available(iOS 18.0, tvOS 18.0, *)
    @discardableResult
    func byAlpha(_ value: CGFloat) -> Self {
        jobs_mutating { $0.alpha = value }
    }

    // ================================== 文本属性 · 主文案 ==================================
    @discardableResult
    func byTextFont(_ font: UIFont) -> Self {
        jobs_mutating { $0.textProperties.font = font }
    }

    @discardableResult
    func byTextColor(_ color: UIColor) -> Self {
        jobs_mutating { $0.textProperties.color = color }
    }

    @discardableResult
    func byTextColorTransformer(_ transformer: UIConfigurationColorTransformer?) -> Self {
        jobs_mutating { $0.textProperties.colorTransformer = transformer }
    }

    @discardableResult
    func byTextAlignment(_ alignment: UIListContentConfiguration.TextProperties.TextAlignment) -> Self {
        jobs_mutating { $0.textProperties.alignment = alignment }
    }

    @discardableResult
    func byTextLineBreakMode(_ mode: NSLineBreakMode) -> Self {
        jobs_mutating { $0.textProperties.lineBreakMode = mode }
    }

    @discardableResult
    func byTextLines(_ numberOfLines: Int) -> Self {
        jobs_mutating { $0.textProperties.numberOfLines = numberOfLines }
    }

    @discardableResult
    func byTextAdjustsFontSizeToFitWidth(_ flag: Bool, minimumScaleFactor: CGFloat? = nil) -> Self {
        jobs_mutating {
            $0.textProperties.adjustsFontSizeToFitWidth = flag
            if let f = minimumScaleFactor { $0.textProperties.minimumScaleFactor = f }
        }
    }

    @discardableResult
    func byTextAllowsDefaultTightening(_ flag: Bool) -> Self {
        jobs_mutating { $0.textProperties.allowsDefaultTighteningForTruncation = flag }
    }

    @discardableResult
    func byTextAdjustsForContentSizeCategory(_ flag: Bool) -> Self {
        jobs_mutating { $0.textProperties.adjustsFontForContentSizeCategory = flag }
    }

    @discardableResult
    func byTextTransform(_ transform: UIListContentConfiguration.TextProperties.TextTransform) -> Self {
        jobs_mutating { $0.textProperties.transform = transform }
    }

    #if targetEnvironment(macCatalyst)
    @available(macCatalyst 16.0, *)
    @discardableResult
    func byTextShowsExpansionWhenTruncated(_ flag: Bool) -> Self {
        jobs_mutating { $0.textProperties.showsExpansionTextWhenTruncated = flag }
    }
    #endif

    // ================================== 文本属性 · 副文案 ==================================
    @discardableResult
    func bySecondaryFont(_ font: UIFont) -> Self {
        jobs_mutating { $0.secondaryTextProperties.font = font }
    }

    @discardableResult
    func bySecondaryColor(_ color: UIColor) -> Self {
        jobs_mutating { $0.secondaryTextProperties.color = color }
    }

    @discardableResult
    func bySecondaryColorTransformer(_ transformer: UIConfigurationColorTransformer?) -> Self {
        jobs_mutating { $0.secondaryTextProperties.colorTransformer = transformer }
    }

    @discardableResult
    func bySecondaryAlignment(_ alignment: UIListContentConfiguration.TextProperties.TextAlignment) -> Self {
        jobs_mutating { $0.secondaryTextProperties.alignment = alignment }
    }

    @discardableResult
    func bySecondaryLines(_ numberOfLines: Int) -> Self {
        jobs_mutating { $0.secondaryTextProperties.numberOfLines = numberOfLines }
    }

    @discardableResult
    func bySecondaryTransform(_ transform: UIListContentConfiguration.TextProperties.TextTransform) -> Self {
        jobs_mutating { $0.secondaryTextProperties.transform = transform }
    }

    // ================================== 图片属性 ==================================
    @discardableResult
    func byPreferredSymbolConfiguration(_ cfg: UIImage.SymbolConfiguration?) -> Self {
        jobs_mutating { $0.imageProperties.preferredSymbolConfiguration = cfg }
    }

    /// 便捷：直接传入 pointSize / weight / scale 生成 `preferredSymbolConfiguration`
    @discardableResult
    func byPreferredSymbol(pointSize: CGFloat? = nil,
                           weight: UIImage.SymbolWeight? = nil,
                           scale: UIImage.SymbolScale? = nil) -> Self {
        let pieces: [UIImage.SymbolConfiguration] = [
            pointSize.map { .init(pointSize: $0) },
            weight.map    { .init(weight: $0)    },
            scale.map     { .init(scale: $0)     }
        ].compactMap { $0 }

        let merged = pieces.reduce(nil as UIImage.SymbolConfiguration?) { acc, cfg in
            acc?.applying(cfg) ?? cfg
        };return byPreferredSymbolConfiguration(merged)
    }

    @discardableResult
    func byTintColor(_ color: UIColor?) -> Self {
        jobs_mutating { $0.imageProperties.tintColor = color }
    }

    @discardableResult
    func byTintColorTransformer(_ transformer: UIConfigurationColorTransformer?) -> Self {
        jobs_mutating { $0.imageProperties.tintColorTransformer = transformer }
    }

    @discardableResult
    func byImageCornerRadius(_ radius: CGFloat) -> Self {
        jobs_mutating { $0.imageProperties.cornerRadius = radius }
    }

    @discardableResult
    func byImageMaximumSize(_ size: CGSize) -> Self {
        jobs_mutating { $0.imageProperties.maximumSize = size }
    }

    /// 为图片预留布局尺寸（即使无图也占位）
    @discardableResult
    func byImageReservedLayoutSize(_ size: CGSize) -> Self {
        jobs_mutating { $0.imageProperties.reservedLayoutSize = size }
    }

    @discardableResult
    func byImageIgnoresInvertColors(_ flag: Bool) -> Self {
        jobs_mutating { $0.imageProperties.accessibilityIgnoresInvertColors = flag }
    }

    @available(iOS 18.0, tvOS 18.0, *)
    @discardableResult
    func byImageStrokeColor(_ color: UIColor?) -> Self {
        jobs_mutating { $0.imageProperties.strokeColor = color }
    }

    @available(iOS 18.0, tvOS 18.0, *)
    @discardableResult
    func byImageStrokeColorTransformer(_ transformer: UIConfigurationColorTransformer?) -> Self {
        jobs_mutating { $0.imageProperties.strokeColorTransformer = transformer }
    }

    @available(iOS 18.0, tvOS 18.0, *)
    @discardableResult
    func byImageStrokeWidth(_ width: CGFloat) -> Self {
        jobs_mutating { $0.imageProperties.strokeWidth = width }
    }

    // ================================== 状态更新 / ContentView ==================================
    /// 对任意 `UIConfigurationState` 做增量更新（一般配合 `UICellConfigurationState` 使用）
    @discardableResult
    func jobsUpdated(for state: UIConfigurationState) -> UIListContentConfiguration {
        self.updated(for: state)
    }

    /// 直接生成 `UIListContentView`
    @MainActor
    func makeJobsContentView() -> (UIView & UIContentView) {
        self.makeContentView()
    }
}

// ================================== Cell 侧便捷接入 ==================================
@available(iOS 14.0, tvOS 14.0, *)
public extension UITableViewCell {
    /// 以链式闭包方式配置并设置 `contentConfiguration`
    @discardableResult
    func byListConfig(_ builder: (UIListContentConfiguration) -> UIListContentConfiguration) -> Self {
        let base = (contentConfiguration as? UIListContentConfiguration) ?? .cell()
        contentConfiguration = builder(base)
        return self
    }
}

@available(iOS 14.0, tvOS 14.0, *)
public extension UICollectionViewListCell {
    /// 以链式闭包方式配置并设置 `contentConfiguration`
    @discardableResult
    func byListConfig(_ builder: (UIListContentConfiguration) -> UIListContentConfiguration) -> Self {
        let base = (contentConfiguration as? UIListContentConfiguration) ?? .cell()
        contentConfiguration = builder(base)
        return self
    }
}
