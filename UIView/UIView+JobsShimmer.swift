//
//  UIView+JobsShimmer.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/2/25.
//

import UIKit
import ObjectiveC
// MARK: - 配置对象
public struct JobsShimmerConfig {
    public var baseColor: UIColor
    public var highlightColor: UIColor
    public var duration: CFTimeInterval
    public var highlightWidthRatio: CGFloat   // 0 ~ 1

    public init(
        baseColor: UIColor = UIColor(white: 0.90, alpha: 1),
        highlightColor: UIColor = UIColor(white: 1.0, alpha: 0.9),
        duration: CFTimeInterval = 1.4,
        highlightWidthRatio: CGFloat = 0.35
    ) {
        self.baseColor = baseColor
        self.highlightColor = highlightColor
        self.duration = duration
        self.highlightWidthRatio = highlightWidthRatio
    }

    public static let `default` = JobsShimmerConfig()
}
// MARK: - 关联 Key
private enum JobsShimmerAssociatedKeys {
    static var layerKey: UInt8  = 0
    static var configKey: UInt8 = 0
    static var isOnKey: UInt8   = 0
}
// MARK: - 私有工具
private extension UIView {
    var jobs_shimmerLayer: CAGradientLayer? {
        get {
            objc_getAssociatedObject(self, &JobsShimmerAssociatedKeys.layerKey) as? CAGradientLayer
        }
        set {
            objc_setAssociatedObject(
                self,
                &JobsShimmerAssociatedKeys.layerKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var jobs_shimmerConfig: JobsShimmerConfig {
        get {
            (objc_getAssociatedObject(self, &JobsShimmerAssociatedKeys.configKey) as? JobsShimmerConfig)
            ?? .default
        }
        set {
            objc_setAssociatedObject(
                self,
                &JobsShimmerAssociatedKeys.configKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var jobs_isShimmeringStored: Bool {
        get {
            (objc_getAssociatedObject(self, &JobsShimmerAssociatedKeys.isOnKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(
                self,
                &JobsShimmerAssociatedKeys.isOnKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    func jobs_prepareShimmerLayerIfNeeded() -> CAGradientLayer {
        if let layer = jobs_shimmerLayer {
            return layer
        }

        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint   = CGPoint(x: 1, y: 0.5)
        self.layer.addSublayer(layer)

        jobs_shimmerLayer = layer
        return layer
    }

    func jobs_updateShimmerColors() {
        guard let layer = jobs_shimmerLayer else { return }

        let cfg = jobs_shimmerConfig

        let c1 = cfg.baseColor.cgColor
        let c2 = cfg.highlightColor.cgColor

        let mid = 0.5
        let half = Double(cfg.highlightWidthRatio) / 2.0
        let start = mid - half
        let end   = mid + half

        layer.colors = [c1, c1, c2, c1, c1]
        layer.locations = [
            0.0 as NSNumber,
            NSNumber(value: start),
            NSNumber(value: mid),
            NSNumber(value: end),
            1.0 as NSNumber
        ]
    }

    func jobs_startShimmerAnimationIfNeeded() {
        guard let layer = jobs_shimmerLayer else { return }
        guard jobs_isShimmeringStored else { return }
        guard layer.animation(forKey: "jobs.shimmer") == nil else { return }

        let cfg = jobs_shimmerConfig
        let w = bounds.width
        guard w > 0 else { return }

        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -w
        animation.toValue   = w
        animation.duration  = cfg.duration
        animation.repeatCount = .greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false

        layer.add(animation, forKey: "jobs.shimmer")
    }
}
// MARK: - 公共 API
public extension UIView {
    /// 是否正在呼吸
    var jobs_isShimmering: Bool {
        get {
            jobs_isShimmeringStored
        }
        set {
            if newValue {
                // 用当前已经保存的 config 重新开启（不会丢自定义配置）
                jobs_startShimmer(config: jobs_shimmerConfig)
            } else {
                jobs_stopShimmer()
            }
        }
    }
    /// 开始呼吸效果
    func jobs_startShimmer(config: JobsShimmerConfig = .default) {
        jobs_shimmerConfig = config
        jobs_isShimmeringStored = true

        clipsToBounds = true   // 和原来的 JobsShimmerBarView 一样

        let layer = jobs_prepareShimmerLayerIfNeeded()

        // 布局和颜色
        jobs_updateShimmerLayout()
        jobs_updateShimmerColors()

        // 动画
        jobs_startShimmerAnimationIfNeeded()

        layer.isHidden = false
    }
    /// 停止呼吸效果
    func jobs_stopShimmer() {
        jobs_isShimmeringStored = false

        jobs_shimmerLayer?.removeAnimation(forKey: "jobs.shimmer")
        jobs_shimmerLayer?.removeFromSuperlayer()
        jobs_shimmerLayer = nil
    }
    /// 视图尺寸变化时调用，更新渐变层 layout（建议在 layoutSubviews 里调用）
    func jobs_updateShimmerLayout() {
        guard let layer = jobs_shimmerLayer, jobs_isShimmeringStored else { return }

        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else { return }

        layer.frame = CGRect(x: -w, y: 0, width: w * 3, height: h)

        let radius = h / 2
        layer.cornerRadius = radius
        self.layer.cornerRadius = max(self.layer.cornerRadius, radius)
    }
    /// 仅给呼吸层设置 mask（SlideToUnlock 用这个来裁掉滑块经过区域）
    func jobs_setShimmerMask(_ maskLayer: CALayer?) {
        jobs_shimmerLayer?.mask = maskLayer
    }
}
// MARK: - DSL
public extension UIView {
    /// DSL：启用/关闭呼吸效果
    @discardableResult
    func byShimmering(_ enabled: Bool,
                      config: JobsShimmerConfig = .default) -> Self {
        if enabled {
            jobs_startShimmer(config: config)
        } else {
            jobs_stopShimmer()
        }
        return self
    }
    /// DSL：修改呼吸颜色（不改变开关状态）
    @discardableResult
    func byShimmerColors(base: UIColor, highlight: UIColor) -> Self {
        var cfg = jobs_shimmerConfig
        cfg.baseColor = base
        cfg.highlightColor = highlight
        jobs_shimmerConfig = cfg
        jobs_updateShimmerColors()
        return self
    }
}
