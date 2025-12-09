//
//  UINavigationBar.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

public extension UINavigationBar {
    // ================================== 基础属性 ==================================
    /// barStyle（.default / .black 等）
    @discardableResult
    func byBarStyle(_ style: UIBarStyle) -> Self {
        barStyle = style
        return self
    }
    /// 是否半透明
    @discardableResult
    func byTranslucent(_ translucent: Bool) -> Self {
        isTranslucent = translucent
        return self
    }
    /// tintColor（按钮、返回箭头等）
    @discardableResult
    func byTintColor(_ color: UIColor?) -> Self {
        tintColor = color
        return self
    }
    /// barTintColor（老 API，iOS13- 主要作用）
    @discardableResult
    func byBarTintColor(_ color: UIColor?) -> Self {
        barTintColor = color
        return self
    }
    /// 是否使用大标题
    @discardableResult
    func byPrefersLargeTitles(_ enable: Bool) -> Self {
        if #available(iOS 11.0, *) {
            prefersLargeTitles = enable
        };return self
    }
    /// 请求的行为风格（iOS16+）
    @discardableResult
    func byPreferredBehavioralStyle(_ style: UIBehavioralStyle) -> Self {
        if #available(iOS 16.0, *) {
            preferredBehavioralStyle = style
        };return self
    }

    @discardableResult
    func byTitleTextAttributes(_ att :[NSAttributedString.Key : Any]?) -> Self {
        titleTextAttributes = att
        return self
    }

    @discardableResult
    func byLargeTitleTextAttributes(_ att :[NSAttributedString.Key : Any]?) -> Self {
        largeTitleTextAttributes = att
        return self
    }
    // ================================== 标题 attributes（旧 API，兼容 iOS13-） ==================================
    @discardableResult
    func byLegacyTitleFont(_ font: UIFont?) -> Self {
        var attrs = titleTextAttributes ?? [:]
        if let font {
            attrs[.font] = font
        } else {
            attrs.removeValue(forKey: .font)
        };titleTextAttributes = attrs
        return self
    }

    @discardableResult
    func byLegacyTitleColor(_ color: UIColor?) -> Self {
        var attrs = titleTextAttributes ?? [:]
        if let color {
            attrs[.foregroundColor] = color
        } else {
            attrs.removeValue(forKey: .foregroundColor)
        };titleTextAttributes = attrs
        return self
    }

    @discardableResult
    func byLegacyLargeTitleFont(_ font: UIFont?) -> Self {
        if #available(iOS 11.0, *) {
            var attrs = largeTitleTextAttributes ?? [:]
            if let font {
                attrs[.font] = font
            } else {
                attrs.removeValue(forKey: .font)
            };largeTitleTextAttributes = attrs
        };return self
    }

    @discardableResult
    func byLegacyLargeTitleColor(_ color: UIColor?) -> Self {
        if #available(iOS 11.0, *) {
            var attrs = largeTitleTextAttributes ?? [:]
            if let color {
                attrs[.foregroundColor] = color
            } else {
                attrs.removeValue(forKey: .foregroundColor)
            };largeTitleTextAttributes = attrs
        };return self
    }
    /// 垂直方向标题偏移（iOS13- 用得多）
    @discardableResult
    func byTitleVerticalOffset(_ offset: CGFloat,
                               for metrics: UIBarMetrics = .default) -> Self {
        setTitleVerticalPositionAdjustment(offset, for: metrics)
        return self
    }
    // ================================== 背景 & 阴影（老 API） ==================================
    /// 背景图片（简单版，按 barMetrics）
    @discardableResult
    func byBackgroundImage(_ image: UIImage?,
                           for metrics: UIBarMetrics = .default) -> Self {
        setBackgroundImage(image, for: metrics)
        return self
    }
    /// 背景图片（带 barPosition）
    @discardableResult
    func byBackgroundImage(_ image: UIImage?,
                           for position: UIBarPosition,
                           metrics: UIBarMetrics = .default) -> Self {
        setBackgroundImage(image, for: position, barMetrics: metrics)
        return self
    }
    /// 阴影图（下划线）
    @discardableResult
    func byShadowImage(_ image: UIImage?) -> Self {
        shadowImage = image
        return self
    }
    /// 返回按钮指示图标
    @discardableResult
    func byBackIndicator(_ image: UIImage?, mask: UIImage? = nil) -> Self {
        backIndicatorImage = image
        backIndicatorTransitionMaskImage = mask ?? image
        return self
    }
    // ================================== Appearance（iOS13+） ==================================
    /// 配置 standardAppearance@闭包版
    @discardableResult
    func byStandardAppearance(_ builder: jobsByNavigationBarAppearanceBlock) -> Self {
        if #available(iOS 13.0, *) {
            let appearance = standardAppearance          // @NSCopying：这里拿到的是 copy
            builder(appearance)
            standardAppearance = appearance
        };return self
    }
    /// 直接设置 standardAppearance
    @discardableResult
    func byStandardAppearance(_ appearance: UINavigationBarAppearance) -> Self {
        if #available(iOS 13.0, *) {
            standardAppearance = appearance
        };return self
    }
    /// 配置 compactAppearance@闭包版（紧凑高度）
    @discardableResult
    func byCompactAppearance(_ builder: jobsByNavigationBarAppearanceBlock) -> Self {
        if #available(iOS 13.0, *) {
            let appearance = compactAppearance ?? standardAppearance
            builder(appearance)
            compactAppearance = appearance
        };return self
    }
    /// 直接设置 compactAppearance（可为 nil）
    @discardableResult
    func byCompactAppearance(_ appearance: UINavigationBarAppearance?) -> Self {
        if #available(iOS 13.0, *) {
            compactAppearance = appearance
        };return self
    }
    /// 配置 scrollEdgeAppearance@闭包版（滚动到边缘时）
    @discardableResult
    func byScrollEdgeAppearance(_ builder: jobsByNavigationBarAppearanceBlock) -> Self {
        if #available(iOS 13.0, *) {
            let appearance = scrollEdgeAppearance ?? standardAppearance
            builder(appearance)
            scrollEdgeAppearance = appearance
        };return self
    }
    /// 直接设置 scrollEdgeAppearance（可为 nil）
    @discardableResult
    func byScrollEdgeAppearance(_ appearance: UINavigationBarAppearance?) -> Self {
        if #available(iOS 13.0, *) {
            scrollEdgeAppearance = appearance
        };return self
    }
    /// 配置 compactScrollEdgeAppearance@闭包版（紧凑 + 滚动到边缘）
    @discardableResult
    func byCompactScrollEdgeAppearance(_ builder: jobsByNavigationBarAppearanceBlock) -> Self {
        if #available(iOS 15.0, *) {
            let appearance = compactScrollEdgeAppearance
                ?? scrollEdgeAppearance
                ?? compactAppearance
                ?? standardAppearance
            builder(appearance)
            compactScrollEdgeAppearance = appearance
        };return self
    }
    /// 直接设置 compactScrollEdgeAppearance（可为 nil）
    @discardableResult
    func byCompactScrollEdgeAppearance(_ appearance: UINavigationBarAppearance?) -> Self {
        if #available(iOS 15.0, *) {
            compactScrollEdgeAppearance = appearance
        };return self
    }
    /// 一次把同一个appearance套到所有状态@闭包版（常用）
    @discardableResult
    func byUnifiedAppearance(_ builder: jobsByNavigationBarAppearanceBlock) -> Self {
        if #available(iOS 13.0, *) {
            let appearance = standardAppearance
            builder(appearance)
            standardAppearance = appearance
            scrollEdgeAppearance = appearance
            compactAppearance = appearance
            if #available(iOS 15.0, *) {
                compactScrollEdgeAppearance = appearance
            }
        };return self
    }
    /// 用同一个 appearance 套到所有状态
    @discardableResult
    func byUnifiedAppearance(_ appearance: UINavigationBarAppearance) -> Self {
        if #available(iOS 13.0, *) {
            standardAppearance = appearance
            scrollEdgeAppearance = appearance
            compactAppearance = appearance
            if #available(iOS 15.0, *) {
                compactScrollEdgeAppearance = appearance
            }
        };return self
    }
    /// 批量设置 items
    @discardableResult
    func byItems(_ items: [UINavigationItem]?,
                 animated: Bool = false) -> Self {
        setItems(items, animated: animated)
        return self
    }
}
