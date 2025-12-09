//
//  UIStackView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

public extension UIStackView {
    @discardableResult
    func byAxis(_ axis: NSLayoutConstraint.Axis) -> Self {
        self.axis = axis
        return self
    }

    @discardableResult
    func byDistribution(_ distribution: UIStackView.Distribution) -> Self {
        self.distribution = distribution
        return self
    }

    @discardableResult
    func byAlignment(_ alignment: UIStackView.Alignment) -> Self {
        self.alignment = alignment
        return self
    }

    @discardableResult
    func bySpacing(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        return self
    }

    @discardableResult
    func byAddArrangedSubview(_ view: UIView) -> Self {
        self.addArrangedSubview(view)
        return self
    }

    @discardableResult
    func addArrangedSubviews(_ views: UIView...) -> Self {
        views.forEach { self.addArrangedSubview($0) }
        return self
    }
    // MARK: - iOS 11.0+ 设置自定义间距（在指定子视图后）
    @available(iOS 11.0, *)
    @discardableResult
    func byCustomSpacing(_ spacing: CGFloat, after view: UIView) -> Self {
        self.setCustomSpacing(spacing, after: view)
        return self
    }
    // MARK: - iOS 11.0+ 获取指定子视图后的间距
    @available(iOS 11.0, *)
    @discardableResult
    func byCustomSpacingAfter(_ view: UIView) -> CGFloat {
        return self.customSpacing(after: view)
    }
    // MARK: - 基线相对布局（适用于文本对齐）
    @discardableResult
    func byBaselineRelativeArrangement(_ enable: Bool) -> Self {
        self.isBaselineRelativeArrangement = enable
        return self
    }
    // MARK: - 是否启用布局边距相对排列
    @discardableResult
    func byLayoutMarginsRelativeArrangement(_ enable: Bool) -> Self {
        self.isLayoutMarginsRelativeArrangement = enable
        return self
    }
    // MARK: - 插入子视图到指定索引
    @discardableResult
    func byInsertArrangedSubview(_ view: UIView, at index: Int) -> Self {
        self.insertArrangedSubview(view, at: index)
        return self
    }
    // MARK: - 移除指定子视图
    @discardableResult
    func byRemoveArrangedSubview(_ view: UIView) -> Self {
        self.removeArrangedSubview(view)
        return self
    }
    // MARK: - 移除所有子视图
    @discardableResult
    func byRemoveAllArrangedSubviews() -> Self {
        self.arrangedSubviews.forEach { self.removeArrangedSubview($0); $0.removeFromSuperview() }
        return self
    }
}

public extension UIStackView {
    // 批量添加（数组版）
    @discardableResult
    func byAddArrangedSubviews(_ views: [UIView]) -> Self {
        views.forEach { self.addArrangedSubview($0) }
        return self
    }
    // 语义化“清空重建”
    @discardableResult
    func byResetArrangedSubviews(_ make: JobsRetViewsByVoidBlock) -> Self {
        self.arrangedSubviews.forEach { self.removeArrangedSubview($0); $0.removeFromSuperview() }
        make().forEach { self.addArrangedSubview($0) }
        return self
    }
    // 开启 layoutMarginsRelative + 设置边距（更好用的安全间距）
    @discardableResult
    func byLayoutMargins(_ insets: UIEdgeInsets, relative: Bool = true) -> Self {
        self.isLayoutMarginsRelativeArrangement = relative
        self.layoutMargins = insets
        return self
    }
}
