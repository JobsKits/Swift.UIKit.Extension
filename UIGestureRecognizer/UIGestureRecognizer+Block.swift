//
//  UIGestureRecognizer+Block.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import ObjectiveC

// ================================== 闭包容器 ==================================
private final class _GestureClosureBox {
    let block: (UIGestureRecognizer) -> Void
    init(_ block: @escaping (UIGestureRecognizer) -> Void) { self.block = block }
}
// ================================== UIGestureRecognizer 链式 block 初始化 ==================================
private var GestureBlockKey: UInt8 = 0
public extension UIGestureRecognizer {
    // MARK: - 通过闭包配置（替代 target/selector）
    static func byConfig(_ block: @escaping (UIGestureRecognizer) -> Void) -> Self {
        let gesture = Self()
        gesture._setActionBlock(block)
        gesture.addTarget(gesture, action: #selector(_gestureInvoke(_:)))
        return gesture
    }
    // MARK: - 为已有手势添加 block（非静态）
    @discardableResult
    func byAction(_ block: @escaping (UIGestureRecognizer) -> Void) -> Self {
        _setActionBlock(block)
        addTarget(self, action: #selector(_gestureInvoke(_:)))
        return self
    }

    @objc private func _gestureInvoke(_ sender: UIGestureRecognizer) {
        (objc_getAssociatedObject(self, &GestureBlockKey) as? _GestureClosureBox)?.block(sender)
    }

    private func _setActionBlock(_ block: @escaping (UIGestureRecognizer) -> Void) {
        objc_setAssociatedObject(self, &GestureBlockKey, _GestureClosureBox(block), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
