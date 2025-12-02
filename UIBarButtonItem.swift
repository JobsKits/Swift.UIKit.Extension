//
//  UIBarButtonItem.swift
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

import ObjectiveC
// MARK: - 私有存储
private var _barItemActionKey: UInt8 = 0
public typealias BarItemHandler = (UIBarButtonItem) -> Void
// MARK: - Block 事件 + 工厂 + 链式
public extension UIBarButtonItem {
    // ========= 1) 事件：不用 #selector，iOS14+ 用 primaryAction，以下自动处理 =========
    /// 绑定点击回调（替代 #selector）
    @discardableResult
    func onTap(_ block: @escaping BarItemHandler) -> Self {
        if #available(iOS 14.0, *) {
            // iOS14+：优先使用 UIAction，不需要 target/action
            self.primaryAction = UIAction { [weak self] _ in
                guard let item = self else { return }
                block(item)
            }
        } else {
            // iOS14-：内部 target/action 兜底，但对外仍是 block
            objc_setAssociatedObject(self, &_barItemActionKey, block, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            self.target = self
            self.action  = #selector(_jobs_handleAction(_:))
        };return self
    }

    @objc private func _jobs_handleAction(_ sender: Any) {
        if let block = objc_getAssociatedObject(self, &_barItemActionKey) as? BarItemHandler {
            block(self)
        }
    }
    // ========= 2) 工厂：不暴露 target/action 的简洁创建 =========
    /// 标题按钮（默认 .plain）
    static func make(title: String?, style: UIBarButtonItem.Style = .plain) -> UIBarButtonItem {
        UIBarButtonItem(title: title, style: style, target: nil, action: nil)
    }
    /// 图片按钮（默认 .plain）
    static func make(image: UIImage?, style: UIBarButtonItem.Style = .plain) -> UIBarButtonItem {
        UIBarButtonItem(image: image, style: style, target: nil, action: nil)
    }
    /// 系统项按钮（如 .done / .cancel / .add 等）
    static func make(systemItem: UIBarButtonItem.SystemItem) -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
    }
    /// 弹性空白（兼容 iOS14-）
    static func flexible() -> UIBarButtonItem {
        if #available(iOS 14.0, *) {
            return .flexibleSpace()
        } else {
            return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        }
    }
    /// 固定空白（iOS26 有 0 宽重载；iOS14 有带宽重载；更低版本用旧 API）
    static func fixed(_ width: CGFloat = 0) -> UIBarButtonItem {
        if #available(iOS 26.0, *), width == 0 {
            return .fixedSpace()
        } else if #available(iOS 14.0, *) {
            return .fixedSpace(width)
        } else {
            let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            item.width = width
            return item
        }
    }
    // ========= 3) 链式：按一贯风格补常用点语法 =========
    @discardableResult
    func byStyle(_ style: UIBarButtonItem.Style) -> Self {
        self.style = style
        return self
    }

    @discardableResult
    func byTintColor(_ color: UIColor?) -> Self {
        self.tintColor = color
        return self
    }
    /// iOS16+ 控制隐藏
    @discardableResult
    func byHidden(_ hidden: Bool) -> Self {
        if #available(iOS 16.0, *) { self.isHidden = hidden }
        return self
    }
    /// iOS15+ 选择态主行为
    @discardableResult
    func byChangesSelectionAsPrimaryAction(_ enable: Bool) -> Self {
        if #available(iOS 15.0, *) { self.changesSelectionAsPrimaryAction = enable }
        return self
    }
    /// iOS15+ 选择态
    @discardableResult
    func bySelected(_ selected: Bool) -> Self {
        if #available(iOS 15.0, *) { self.isSelected = selected }
        return self
    }
    /// iOS14+ 直接挂菜单
    @discardableResult
    func byMenu(_ menu: UIMenu?) -> Self {
        if #available(iOS 14.0, *) { self.menu = menu }
        return self
    }
    /// iOS16+ 优先级
    @discardableResult
    @available(iOS 16.0, *)
    func byPreferredMenuOrder(_ order: UIContextMenuConfiguration.ElementOrder) -> Self {
        self.preferredMenuElementOrder = order
        return self
    }
    /// 标题位置微调（兼容老系统）
    @discardableResult
    func byTitleOffset(_ offset: UIOffset, for metrics: UIBarMetrics = .default) -> Self {
        setTitlePositionAdjustment(offset, for: metrics)
        return self
    }
}
