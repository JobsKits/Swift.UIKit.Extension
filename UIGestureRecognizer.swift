//
//  UIGestureRecognizer.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/27/25.
//

import UIKit
import ObjectiveC
import RxSwift
import RxCocoa
import NSObject_Rx          // 自动提供 disposeBag
/**
 let tap = UITapGestureRecognizer()
     .byTarget(self, action: #selector(onTap))
     .byCancelsTouchesInView(true)
     .byRequiresExclusiveTouchType(false)
     .byName("customTap")
     .byEnabled(true)
 */
public extension UIGestureRecognizer {
    // MARK: - 初始化方法封装
    @discardableResult
    func byTarget(_ target: Any?, action: Selector?) -> Self {
        // ⚠️ 注意：这里不是安全复用的做法，仅供链式设置使用
        if let target, let action {
            self.addTarget(target, action: action)
        }
        return self
    }
    // MARK: - Delegate
    @discardableResult
    func byDelegate(_ delegate: UIGestureRecognizerDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
    // MARK: - 是否启用
    @discardableResult
    func byEnabled(_ isEnabled: Bool) -> Self {
        self.isEnabled = isEnabled
        return self
    }
    // MARK: - 触摸控制属性
    @discardableResult
    func byCancelsTouchesInView(_ value: Bool) -> Self {
        self.cancelsTouchesInView = value
        return self
    }

    @discardableResult
    func byDelaysTouchesBegan(_ value: Bool) -> Self {
        self.delaysTouchesBegan = value
        return self
    }

    @discardableResult
    func byDelaysTouchesEnded(_ value: Bool) -> Self {
        self.delaysTouchesEnded = value
        return self
    }
    // MARK: - iOS9+ 触摸类型
    @available(iOS 9.0, *)
    @discardableResult
    func byAllowedTouchTypes(_ types: [NSNumber]) -> Self {
        self.allowedTouchTypes = types
        return self
    }

    @available(iOS 9.0, *)
    @discardableResult
    func byAllowedPressTypes(_ types: [NSNumber]) -> Self {
        self.allowedPressTypes = types
        return self
    }
    // MARK: - iOS9.2+ 独占触摸
    @available(iOS 9.2, *)
    @discardableResult
    func byRequiresExclusiveTouchType(_ value: Bool) -> Self {
        self.requiresExclusiveTouchType = value
        return self
    }
    // MARK: - iOS11+ 手势命名
    @available(iOS 11.0, *)
    @discardableResult
    func byName(_ name: String?) -> Self {
        self.name = name
        return self
    }
    // MARK: - iOS13.4+ 键盘修饰符 / 鼠标按钮
    @available(iOS 13.4, *)
    @discardableResult
    func byModifierFlags(_ flags: UIKeyModifierFlags) -> Self {
        // modifierFlags 是只读属性，仅供获取，无可写入 setter
        // 所以这里只能做空实现以保持风格统一
        return self
    }

    @available(iOS 13.4, *)
    @discardableResult
    func byButtonMask(_ mask: UIEvent.ButtonMask) -> Self {
        // 同上，buttonMask 也是只读
        return self
    }
    // MARK: - 公共辅助方法
    @discardableResult
    func byRequireToFail(_ other: UIGestureRecognizer) -> Self {
        self.require(toFail: other)
        return self
    }
}
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
// ================================== 子类专属链式扩展 ==================================
public extension UITapGestureRecognizer {
    @discardableResult func byTaps(_ count: Int) -> Self { numberOfTapsRequired = count; return self }
    @discardableResult func byTouches(_ count: Int) -> Self { numberOfTouchesRequired = count; return self }
}

public extension UILongPressGestureRecognizer {
    @discardableResult func byMinDuration(_ t: TimeInterval) -> Self { minimumPressDuration = t; return self }
    @discardableResult func byMovement(_ v: CGFloat) -> Self { allowableMovement = v; return self }
    @discardableResult func byTouches(_ n: Int) -> Self { numberOfTouchesRequired = n; return self }
}

public extension UIPanGestureRecognizer {
    @discardableResult func byMinTouches(_ n: Int) -> Self { minimumNumberOfTouches = n; return self }
    @discardableResult func byMaxTouches(_ n: Int) -> Self {
        if maximumNumberOfTouches != Int.max {maximumNumberOfTouches = n;}
        return self
    }
}

public extension UISwipeGestureRecognizer {
    @discardableResult func byDirection(_ d: UISwipeGestureRecognizer.Direction) -> Self { direction = d; return self }
    @discardableResult func byTouches(_ n: Int) -> Self { numberOfTouchesRequired = n; return self }
}
// ================================== Pinch（捏合缩放） ==================================
public extension UIPinchGestureRecognizer {
    // MARK: - 当前缩放比例（scale）
    @discardableResult
    func byScale(_ value: CGFloat) -> Self {
        self.scale = value
        return self
    }
    // MARK: - 复位缩放比例到默认值 1.0
    @discardableResult
    func byResetScale() -> Self {
        self.scale = 1.0
        return self
    }
    // MARK: - 在闭包里获取当前 scale
    @discardableResult
    func byOnScaleChange(_ block: @escaping (UIPinchGestureRecognizer, CGFloat) -> Void) -> Self {
        self.byAction { gesture in
            if let pinch = gesture as? UIPinchGestureRecognizer {
                block(pinch, pinch.scale)
            }
        };return self
    }
}
// ================================== Rotation（旋转） ==================================
public extension UIRotationGestureRecognizer {
    // MARK: - 当前旋转角度（弧度）
    @discardableResult
    func byRotation(_ value: CGFloat) -> Self {
        self.rotation = value
        return self
    }
    // MARK: - 复位旋转角度为 0
    @discardableResult
    func byResetRotation() -> Self {
        self.rotation = 0
        return self
    }
    // MARK: - 在闭包里获取旋转角度
    @discardableResult
    func byOnRotationChange(_ block: @escaping (UIRotationGestureRecognizer, CGFloat) -> Void) -> Self {
        self.byAction { gesture in
            if let rot = gesture as? UIRotationGestureRecognizer {
                block(rot, rot.rotation)
            }
        };return self
    }
}

public extension UITapGestureRecognizer {
    /// 语义属性：等价于 `.rx.event`
    var event: ControlEvent<UITapGestureRecognizer> {
        self.rx.event
    }
}
