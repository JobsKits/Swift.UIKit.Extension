//
//  UIView+动画.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
// MARK: 动画@旋转
private var _spinKey: UInt8 = 0   // 动画是否已装
private var _timeKey: UInt8 = 0   // 暂停时的时间戳
public extension UIView {
    /// 是否正在旋转（装了动画且 layer.speed == 1）
    var jobs_isSpinning: Bool {
        layer.animation(forKey: "jobs.spin") != nil && layer.speed == 1
    }
    /// 是否处于暂停（装了动画但 speed == 0）
    var jobs_isSpinPaused: Bool {
        layer.animation(forKey: "jobs.spin") != nil && layer.speed == 0
    }
    /// 开始旋转（基于 CALayer，不改 view.transform；与点击放大可叠加）
    @discardableResult
    func bySpinStart(revPerSec: Double = 1.0) -> Self {
        // 已有就别重复装
        if layer.animation(forKey: "jobs.spin") == nil {
            let a = CABasicAnimation(keyPath: "transform.rotation.z")
            a.fromValue = 0
            a.toValue = Double.pi * 2
            a.duration = 1.0 / max(0.001, revPerSec)   // 一秒转 revPerSec 圈
            a.repeatCount = .infinity
            a.isRemovedOnCompletion = false
            a.fillMode = .forwards
            layer.add(a, forKey: "jobs.spin")
        }
        // 确保运行态
        layer.speed = 1
        layer.timeOffset = 0
        layer.beginTime = 0
        return self
    }
    /// 暂停旋转（保持当前角度）
    @discardableResult
    func bySpinPause() -> Self {
        guard layer.animation(forKey: "jobs.spin") != nil, layer.speed != 0 else { return self }
        let paused = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0
        layer.timeOffset = paused
        return self
    }
    /// 恢复旋转（从暂停角度继续）
    @discardableResult
    func bySpinResume() -> Self {
        guard layer.animation(forKey: "jobs.spin") != nil, layer.speed == 0 else { return self }
        let paused = layer.timeOffset
        layer.speed = 1
        layer.timeOffset = 0
        layer.beginTime = 0
        let sincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - paused
        layer.beginTime = sincePause
        return self
    }
    /// 停止并移除旋转动画
    @discardableResult
    func bySpinStop() -> Self {
        layer.removeAnimation(forKey: "jobs.spin")
        layer.speed = 1
        layer.timeOffset = 0
        layer.beginTime = 0
        return self
    }
}
// MARK: 动画@点击放大
private var _jobs_bounceAnimatingKey: UInt8 = 0
@MainActor
public extension UIView {
    /// 仅执行一轮“放大→回弹”动画（不挂手势/不注册事件）
    func playTapBounce(
        scale: CGFloat = 1.08,
        upDuration: TimeInterval = 0.08,
        downDuration: TimeInterval = 0.30,
        damping: CGFloat = 0.66,
        velocity: CGFloat = 0.9,
        haptic: UIImpactFeedbackGenerator.FeedbackStyle? = nil
    ) {
        // 去抖：正在做上一轮就不叠加
        if (objc_getAssociatedObject(self, &_jobs_bounceAnimatingKey) as? Bool) == true { return }
        objc_setAssociatedObject(self, &_jobs_bounceAnimatingKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // 以“当前 transform”为基准，避免覆盖你已有的旋转/缩放
        let original = self.transform
        if let style = haptic { UIImpactFeedbackGenerator(style: style).impactOccurred() }

        UIView.animate(withDuration: upDuration,
                       delay: 0,
                       options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut]) { [weak self] in
            guard let self else { return }
            self.transform = original.scaledBy(x: max(0.01, scale), y: max(0.01, scale))
        } completion: { [weak self] _ in
            guard let self else { return }
            UIView.animate(withDuration: downDuration,
                           delay: 0,
                           usingSpringWithDamping: max(0.05, min(1, damping)),
                           initialSpringVelocity: max(0, velocity),
                           options: [.beginFromCurrentState, .allowUserInteraction]) { [weak self] in
                self?.transform = original
            } completion: { [weak self] _ in
                objc_setAssociatedObject(self as Any, &_jobs_bounceAnimatingKey, false, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
// MARK: 动画@视图左右晃动
extension UIView {
    func shake(duration: CFTimeInterval = 0.5, repeatCount: Float = 1) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.values = [-10, 10, -8, 8, -5, 5, 0] // 左右偏移
        animation.repeatCount = repeatCount
        self.layer.add(animation, forKey: "shake")
    }
}
