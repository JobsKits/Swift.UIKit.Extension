//
//  UIView+Subview.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
@MainActor
public extension UIView {
    func _allSubviews() -> [UIView] { subviews + subviews.flatMap { $0._allSubviews() } }
    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        // 只查一层足够；要递归可以展开
        return subviews.first { $0 is T } as? T
    }
    func _firstSubview<T: UIView>(of type: T.Type) -> T? {
        if let s = self as? T { return s }
        for v in subviews { if let hit = v._firstSubview(of: type) { return hit } }
        return nil
    }
    /// 递归收集指定类型的所有子视图（避免与已有 `_allSubviews()` 重名）
    func _recursiveSubviews<T: UIView>(of type: T.Type) -> [T] {
        var result: [T] = []
        for sub in subviews {
            if let t = sub as? T { result.append(t) }
            result.append(contentsOf: sub._recursiveSubviews(of: type))
        };return result
    }
    /// 向上寻找满足条件的祖先
    func _firstAncestor(where predicate: (UIView) -> Bool) -> UIView? {
        var p = superview
        while let v = p {
            if predicate(v) { return v }
            p = v.superview
        };return nil
    }
}
