//
//  UIView+JobsCountdownFuse.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/10/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

import ObjectiveC
/// 导火索式倒计时：在任意 UIView 最外层画一圈可消耗的边框，随着时间递减
/// 导火索倒计时配置（按需可以继续扩）
/// 这里先做最小配置：线宽、颜色、内边距、结束后是否移除
public struct JobsFuseConfig {
    /// 动画方向：顺时针 / 逆时针
    public enum Direction {
        /// 逆时针：当前行为（strokeEnd: 1 → 0）
        case counterClockwise
        /// 顺时针：改为动 strokeStart: 0 → 1
        case clockwise
    }
    public var lineWidth: CGFloat
    public var color: UIColor
    public var inset: CGFloat
    public var removeOnFinish: Bool
    public var direction: Direction

    public init(lineWidth: CGFloat = 4,
                color: UIColor = .systemRed,
                inset: CGFloat = 0,
                removeOnFinish: Bool = true,
                direction: Direction = .counterClockwise) {
        self.lineWidth = lineWidth
        self.color = color
        self.inset = inset
        self.removeOnFinish = removeOnFinish
        self.direction = direction
    }
}

public extension UIView {
    // MARK: - Associated Keys
    private struct JobsFuseKeys {
        static var processKey: UInt8 = 0   // 先保留，外部类型不改
        static var layerKey: UInt8 = 0
        static var configKey: UInt8 = 0
        static var completionKey: UInt8 = 0
    }
    /// 旧的倒计时 Process（现在基本不用了，只是为了兼容）
    private var jobs_fuseProcess: JobsCountdownProcess? {
        get {
            objc_getAssociatedObject(self, &JobsFuseKeys.processKey) as? JobsCountdownProcess
        }
        set {
            objc_setAssociatedObject(self,
                                     &JobsFuseKeys.processKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var jobs_fuseLayer: CAShapeLayer? {
        get {
            objc_getAssociatedObject(self, &JobsFuseKeys.layerKey) as? CAShapeLayer
        }
        set {
            objc_setAssociatedObject(self,
                                     &JobsFuseKeys.layerKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var jobs_fuseConfig: JobsFuseConfig? {
        get {
            objc_getAssociatedObject(self, &JobsFuseKeys.configKey) as? JobsFuseConfig
        }
        set {
            objc_setAssociatedObject(self,
                                     &JobsFuseKeys.configKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var jobs_fuseCompletion: (() -> Void)? {
        get {
            objc_getAssociatedObject(self, &JobsFuseKeys.completionKey) as? (() -> Void)
        }
        set {
            objc_setAssociatedObject(self,
                                     &JobsFuseKeys.completionKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    // MARK: - 公共 API
    /// DSL 写法：在当前视图上挂一个导火索倒计时
    @discardableResult
    func byFuseCountdown(duration: TimeInterval,
                         config: JobsFuseConfig = JobsFuseConfig(),
                         finished: (() -> Void)? = nil) -> Self {
        jobs_startFuseCountdown(duration: duration,
                                config: config,
                                finished: finished)
        return self
    }
    /// 显式启动导火索倒计时（现在用 CABasicAnimation 驱动 strokeEnd / strokeStart）
    ///
    /// - Parameters:
    ///   - duration: 总时长（秒）
    ///   - config: 外观配置（线宽、颜色、inset、方向）
    ///   - finished: 结束时回调
    @discardableResult
    func jobs_startFuseCountdown(duration: TimeInterval,
                                 config: JobsFuseConfig = JobsFuseConfig(),
                                 finished: (() -> Void)? = nil) -> JobsCountdownProcess? {
        layoutIfNeeded()
        guard bounds.width > 0, bounds.height > 0, duration > 0 else {
            // 没尺寸或者 duration <= 0，直接清掉
            jobs_cancelFuseCountdown()
            finished?()
            return nil
        }
        // 先停掉旧的 Process & 动画（保留 layer）
        jobs_cancelFuseCountdown(removeLayer: false)
        jobs_fuseConfig = config
        jobs_fuseCompletion = finished

        // 拿到 / 创建 Layer
        let fuseLayer: CAShapeLayer
        if let existing = jobs_fuseLayer {
            fuseLayer = existing
        } else {
            fuseLayer = CAShapeLayer()
            fuseLayer.fillColor = UIColor.clear.cgColor
            fuseLayer.lineCap = .round
            layer.addSublayer(fuseLayer)
            jobs_fuseLayer = fuseLayer
        }
        // 配置 Layer 几何与样式
        fuseLayer.frame = bounds

        let inset = config.inset + config.lineWidth / 2.0
        let rect = bounds.insetBy(dx: inset, dy: inset)
        let cornerRadius = self.layer.cornerRadius
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)

        fuseLayer.path = path.cgPath
        fuseLayer.lineWidth = config.lineWidth
        fuseLayer.strokeColor = config.color.cgColor

        // 重置到“满格”状态（禁用隐式动画）
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fuseLayer.strokeStart = 0
        fuseLayer.strokeEnd = 1
        CATransaction.commit()
        // 用 CABasicAnimation 按方向动 strokeStart / strokeEnd
        let animKey = "jobsFuseStroke"

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            guard let self else { return }

            if config.removeOnFinish {
                self.jobs_removeFuseLayer()
            } else {
                // 不移除时，保持最终状态
                switch config.direction {
                case .counterClockwise:
                    self.jobs_fuseLayer?.strokeEnd = 0
                case .clockwise:
                    self.jobs_fuseLayer?.strokeStart = 1
                }
            }
            self.jobs_fuseCompletion?()
            self.jobs_fuseCompletion = nil
        }
        let anim: CABasicAnimation
        switch config.direction {
        case .counterClockwise:
            // 旧行为：尾巴往回缩，视觉上逆时针烧
            anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = 1.0
            anim.toValue = 0.0
        case .clockwise:
            // 固定 end = 1，头往前推，视觉上顺时针烧
            anim = CABasicAnimation(keyPath: "strokeStart")
            anim.fromValue = 0.0
            anim.toValue = 1.0
        }

        anim.duration = duration
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false

        fuseLayer.add(anim, forKey: animKey)
        CATransaction.commit()

        // 现在不再依赖 JobsCountdownProcess，直接返回 nil 即可
        jobs_fuseProcess = nil
        return nil
    }
    /// 取消导火索倒计时
    func jobs_cancelFuseCountdown(removeLayer: Bool = true) {
        // 兼容旧的 Process
        jobs_fuseProcess?.cancel()
        jobs_fuseProcess = nil
        // 移除动画
        jobs_fuseLayer?.removeAnimation(forKey: "jobsFuseStroke")
        if removeLayer {
            jobs_removeFuseLayer()
        }
    }
    // MARK: - 手动刷新布局（如果你在动画中改变了 view 的大小，可选调用）
    /// 如果 view 的 bounds 发生改变，想让导火索跟着更新一圈，可以在外面的 layoutSubviews/动画回调里手动调一下
    func jobs_layoutFuseIfNeeded() {
        guard let fuseLayer = jobs_fuseLayer,
              let config = jobs_fuseConfig else { return }
        layoutIfNeeded()
        fuseLayer.frame = bounds
        let inset = config.inset + config.lineWidth / 2.0
        let rect = bounds.insetBy(dx: inset, dy: inset)
        let cornerRadius = self.layer.cornerRadius
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        fuseLayer.path = path.cgPath
    }
    // MARK: - Private
    private func jobs_removeFuseLayer() {
        jobs_fuseLayer?.removeFromSuperlayer()
        jobs_fuseLayer = nil
    }
}
