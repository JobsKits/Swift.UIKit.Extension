//
//  UITableView+DequeueReusable.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
// MARK: - 🍬语法糖@复用
extension UITableView {
    /// 快捷复用@UITableViewCell
    public func py_dequeueReusableCell<T: UITableViewCell>(withType cellType: T.Type, for indexPath: IndexPath) -> T {
        let reuseId = cellType.className
        // 先探测一下有没有为这个 identifier 注册
        if dequeueReusableCell(withIdentifier: reuseId) == nil {
            // 没注册就自动注册这个 cellType 自己
            registerCell(cellType)
        };return self.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! T
    }
    /// 快捷复用@UITableViewHeaderFooterView
    public func py_dequeueReusableHeaderFooterView<T: UIView>(headerFooterViewWithType: T.Type) -> T {
        let reuseId = headerFooterViewWithType.className
        // 先探测一下有没有为这个 identifier 注册
        if dequeueReusableHeaderFooterView(withIdentifier: reuseId) == nil {
            // 没注册就自动注册这个 cellType 自己
            py_register(headerFooterViewClassType: headerFooterViewWithType)
        };return self.dequeueReusableHeaderFooterView(withIdentifier: reuseId) as! T
    }
}
