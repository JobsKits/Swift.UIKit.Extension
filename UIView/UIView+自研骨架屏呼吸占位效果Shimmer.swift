//
//  UIView+自研骨架屏呼吸占位效果Shimmer.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/2/25.
//
//  ================================== 自述 ==================================
//  这是一个给任意 UIView 添加「Shimmer / 骨架屏扫光」效果的扩展。
//
//  ✅ 用法：
//  - 开启：view.jobs_startShimmer()
//  - 结束：view.jobs_stopShimmer()
//  - 尺寸变化（约束/旋转/复用）时：在 layoutSubviews / layoutSpecThatFits / didLayout 中调用
//    view.jobs_updateShimmerLayout()
//
//  ✅ 特性：
//  - 使用 CAGradientLayer + CABasicAnimation 实现水平扫光。
//  - 自动处理 bounds 变化：宽度变化时会重建动画，避免扫光距离不对。
//  - highlightWidthRatio / duration 做了安全 clamp，避免无效 locations 或 0 时长。
//  - 会临时开启 clipsToBounds，并在 stop 时恢复原值；同理会临时提升 cornerRadius 并恢复，
//    避免对宿主 view 产生“永久副作用”。
//  - 颜色使用 resolvedColor(with:) 支持暗黑模式动态色（若外部在 trait 变化时调用 refresh）。
//
//  ⚠️ 列表复用建议：cell.prepareForReuse() 里调用 jobs_stopShimmer()，避免残留 layer/动画。
//  ========================================================================

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import ObjectiveC

// MARK: - 自动跟随布局更新（无需子类化）
// 说明：很多时候 startShimmer 发生在 AutoLayout 真正出 frame 之前（bounds=0），
// 如果外部又无法在 layoutSubviews / viewDidLayoutSubviews 里手动调用 update，
// 那么 shimmer 可能永远不会“启动”。
//
// 这里通过轻量 swizzle UIView.layoutSubviews：
// - 仅当 view 正在 shimmer 时才调用 jobs_updateShimmerLayout()
// - 外部无需子类化 UIButton / UIView
private enum JobsShimmerSwizzle {
    static let once: Void = {
        let cls: AnyClass = UIView.self
        let originalSel = #selector(UIView.layoutSubviews)
        let swizzledSel = #selector(UIView.jobs_shimmer_layoutSubviews)
        guard let original = class_getInstanceMethod(cls, originalSel),
              let swizzled = class_getInstanceMethod(cls, swizzledSel) else {
            return
        }
        method_exchangeImplementations(original, swizzled)
    }()
}

private extension UIView {
    static func jobs_enableShimmerAutoLayoutUpdatesOnce() {
        _ = JobsShimmerSwizzle.once
    }

    @objc func jobs_shimmer_layoutSubviews() {
        // 注意：交换实现后，这里调用的是“原始 layoutSubviews”
        self.jobs_shimmer_layoutSubviews()
        guard jobs_isShimmeringStored else { return }
        jobs_updateShimmerLayout()
    }
}
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
    static var originClipsKey: UInt8 = 0
    static var originCornerKey: UInt8 = 0
    static var lastAnimWidthKey: UInt8 = 0
}
// MARK: - 私有工具
private extension UIView {
    func jobs_withoutImplicitAnimations(_ block: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        block()
        CATransaction.commit()
    }

    var jobs_originalClipsToBounds: Bool? {
        get { objc_getAssociatedObject(self, &JobsShimmerAssociatedKeys.originClipsKey) as? Bool }
        set {
            objc_setAssociatedObject(
                self,
                &JobsShimmerAssociatedKeys.originClipsKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var jobs_originalCornerRadius: CGFloat? {
        get {
            if let n = objc_getAssociatedObject(self, &JobsShimmerAssociatedKeys.originCornerKey) as? NSNumber {
                return CGFloat(truncating: n)
            }
            return nil
        }
        set {
            let boxed = newValue.map { NSNumber(value: Double($0)) }
            objc_setAssociatedObject(
                self,
                &JobsShimmerAssociatedKeys.originCornerKey,
                boxed,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var jobs_lastAnimationWidth: CGFloat? {
        get {
            if let n = objc_getAssociatedObject(self, &JobsShimmerAssociatedKeys.lastAnimWidthKey) as? NSNumber {
                return CGFloat(truncating: n)
            }
            return nil
        }
        set {
            let boxed = newValue.map { NSNumber(value: Double($0)) }
            objc_setAssociatedObject(
                self,
                &JobsShimmerAssociatedKeys.lastAnimWidthKey,
                boxed,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

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
        layer.name = "jobs.shimmer.layer"
        // 禁用布局更新时的隐式动画（避免闪一下）
        layer.actions = [
            "bounds": NSNull(),
            "position": NSNull(),
            "frame": NSNull(),
            "cornerRadius": NSNull(),
            "contents": NSNull(),
            "colors": NSNull(),
            "locations": NSNull()
        ]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint   = CGPoint(x: 1, y: 0.5)
        self.layer.addSublayer(layer)

        jobs_shimmerLayer = layer
        return layer
    }

    func jobs_updateShimmerColors() {
        guard let layer = jobs_shimmerLayer else { return }

        let cfg = jobs_shimmerConfig

        // 动态色支持：resolvedColor(with:) 可跟随暗黑模式变化
        let base = cfg.baseColor.resolvedColor(with: traitCollection)
        let highlight = cfg.highlightColor.resolvedColor(with: traitCollection)
        let c1 = base.cgColor
        let c2 = highlight.cgColor

        let ratio = min(max(cfg.highlightWidthRatio, 0), 1)
        let mid = 0.5
        let half = Double(ratio) / 2.0
        let start = max(0, mid - half)
        let end   = min(1, mid + half)

        layer.colors = [c1, c1, c2, c1, c1]
        layer.locations = [
            0.0 as NSNumber,
            NSNumber(value: start),
            NSNumber(value: mid),
            NSNumber(value: end),
            1.0 as NSNumber
        ]
    }

    func jobs_startShimmerAnimationIfNeeded(forceRestartIfWidthChanged: Bool = false) {
        guard let layer = jobs_shimmerLayer else { return }
        guard jobs_isShimmeringStored else { return }

        let cfg = jobs_shimmerConfig
        let w = bounds.width
        guard w > 0 else { return }

        if forceRestartIfWidthChanged {
            let last = jobs_lastAnimationWidth ?? 0
            if abs(last - w) > 0.5 {
                layer.removeAnimation(forKey: "jobs.shimmer")
            }
        }

        guard layer.animation(forKey: "jobs.shimmer") == nil else {
            jobs_lastAnimationWidth = w
            return
        }

        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -w
        animation.toValue   = w
        animation.duration  = max(cfg.duration, 0.01)
        animation.repeatCount = .greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .linear)

        layer.add(animation, forKey: "jobs.shimmer")
        jobs_lastAnimationWidth = w
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
        // ✅ 无需子类化：自动跟随布局变化刷新 shimmer layer frame
        UIView.jobs_enableShimmerAutoLayoutUpdatesOnce()

        // 记录原始状态（仅首次开启时记录，stop 时会清理）
        if jobs_originalClipsToBounds == nil {
            jobs_originalClipsToBounds = clipsToBounds
        }
        if jobs_originalCornerRadius == nil {
            jobs_originalCornerRadius = layer.cornerRadius
        }

        jobs_shimmerConfig = config
        jobs_isShimmeringStored = true

        // 临时开启裁剪：因为 shimmer layer 会比 bounds 更宽（-w...3w）
        clipsToBounds = true

        let layer = jobs_prepareShimmerLayerIfNeeded()

        // 布局和颜色
        jobs_updateShimmerLayout()
        jobs_updateShimmerColors()

        // 动画
        jobs_startShimmerAnimationIfNeeded(forceRestartIfWidthChanged: true)

        layer.isHidden = false
    }
    /// 停止呼吸效果
    func jobs_stopShimmer() {
        jobs_isShimmeringStored = false

        jobs_shimmerLayer?.removeAnimation(forKey: "jobs.shimmer")
        jobs_shimmerLayer?.removeFromSuperlayer()
        jobs_shimmerLayer = nil

        // 恢复原始属性，避免对宿主 view 产生永久副作用
        if let originClips = jobs_originalClipsToBounds {
            clipsToBounds = originClips
        }
        if let originCorner = jobs_originalCornerRadius {
            jobs_withoutImplicitAnimations { layer.cornerRadius = originCorner }
        }

        jobs_originalClipsToBounds = nil
        jobs_originalCornerRadius = nil
        jobs_lastAnimationWidth = nil
    }
    /// 视图尺寸变化时调用，更新渐变层 layout（建议在 layoutSubviews 里调用）
    func jobs_updateShimmerLayout() {
        guard let layer = jobs_shimmerLayer, jobs_isShimmeringStored else { return }

        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else { return }

        jobs_withoutImplicitAnimations {
            layer.frame = CGRect(x: -w, y: 0, width: w * 3, height: h)

            // 复刻“bar view”常见的圆角效果：
            // - 如果外部已经给 view 配了 cornerRadius，则尊重外部
            // - 否则默认使用 pill（h/2）
            let baseCorner = jobs_originalCornerRadius ?? self.layer.cornerRadius
            let desiredCorner = max(baseCorner, h / 2)

            layer.cornerRadius = desiredCorner
            self.layer.cornerRadius = max(self.layer.cornerRadius, desiredCorner)
        }

        // ✅ 尺寸变化后，确保动画距离正确
        jobs_startShimmerAnimationIfNeeded(forceRestartIfWidthChanged: true)
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
// MARK: - UIButton 前景图 Loading Shimmer Overlay（无需子类化）
private enum JobsUIButtonFGOverlayAOKeys {
    static var overlayKey: UInt8 = 0
    static var targetSizeKey: UInt8 = 0
}

private enum JobsUIButtonFGOverlaySwizzle {
    static let once: Void = {
        let cls: AnyClass = UIButton.self
        let originalSel = #selector(UIButton.layoutSubviews)
        let swizzledSel = #selector(UIButton.jobs_fgOverlay_layoutSubviews)
        guard let original = class_getInstanceMethod(cls, originalSel),
              let swizzled = class_getInstanceMethod(cls, swizzledSel) else { return }
        method_exchangeImplementations(original, swizzled)
    }()
}

private extension UIButton {
    static func jobs_enableForegroundOverlayAutoLayoutUpdatesOnce() {
        _ = JobsUIButtonFGOverlaySwizzle.once
    }

    var jobs_fgOverlayTargetSize: CGSize? {
        get {
            if let v = objc_getAssociatedObject(self, &JobsUIButtonFGOverlayAOKeys.targetSizeKey) as? NSValue {
                return v.cgSizeValue
            };return nil
        }
        set {
            let boxed = newValue.map { NSValue(cgSize: $0) }
            objc_setAssociatedObject(self, &JobsUIButtonFGOverlayAOKeys.targetSizeKey, boxed, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var jobs_fgShimmerOverlayView: UIView? {
        get { objc_getAssociatedObject(self, &JobsUIButtonFGOverlayAOKeys.overlayKey) as? UIView }
        set { objc_setAssociatedObject(self, &JobsUIButtonFGOverlayAOKeys.overlayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func jobs_getOrCreateFGOverlayView() -> UIView {
        if let v = jobs_fgShimmerOverlayView { return v }
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        v.isHidden = true
        self.addSubview(v)
        jobs_fgShimmerOverlayView = v
        return v
    }

    func jobs_fgOverlayRect(targetSize: CGSize) -> CGRect {
        let b = self.bounds
        guard b.width > 1, b.height > 1 else { return .zero }

        // ✅ 最优先：直接取 imageView 的最终布局结果（最贴近系统真实呈现）
        // - 你的「先灌入兜底图撑开」策略下，这里通常能拿到一个稳定的 frame
        if let iv = self.imageView {
            let s = iv.bounds.size
            if s.width > 1, s.height > 1 {
                return iv.frame.integral
            }
        }

        let content = self.contentRect(forBounds: b)
        let r = self.imageRect(forContentRect: content)

        // 能算出 image rect 就用它（有 image / 有配置尺寸时）
        if r.width > 1, r.height > 1 {
            return r.integral
        }

        // 否则用目标尺寸兜底（请求开始时 image=nil，系统可能算不出 imageRect）
        let w = min(max(targetSize.width, 1), content.width)
        let h = min(max(targetSize.height, 1), content.height)

        let x: CGFloat
        switch self.contentHorizontalAlignment {
        case .right:  x = content.maxX - w
        case .center: x = content.midX - w / 2
        case .fill:   x = content.minX
        default:      x = content.minX
        }

        let y: CGFloat
        switch self.contentVerticalAlignment {
        case .top:    y = content.minY
        case .bottom: y = content.maxY - h
        case .fill:   y = content.minY
        default:      y = content.midY - h / 2
        }

        return CGRect(x: x, y: y, width: w, height: h).integral
    }

    func jobs_layoutFGOverlayIfNeeded() {
        guard let overlay = jobs_fgShimmerOverlayView, !overlay.isHidden else { return }
        let size = jobs_fgOverlayTargetSize ?? CGSize(width: 48, height: 48)
        let r = jobs_fgOverlayRect(targetSize: size)
        guard r.width > 1, r.height > 1 else { return }

        overlay.frame = r
        // ✅ 圆角：优先贴合 imageView，其次走默认
        if let iv = self.imageView, iv.layer.cornerRadius > 0 {
            overlay.layer.cornerRadius = iv.layer.cornerRadius
        } else {
            overlay.layer.cornerRadius = min(r.height / 2, 12)
        }
        overlay.clipsToBounds = true

        // ✅ 兜底：确保 overlay 永远在最上面（避免 UIButton 内部重排子视图后被盖住）
        bringSubviewToFront(overlay)

        // 只有在 shimmer 开启时才刷新 shimmer layer
        if overlay.jobs_isShimmering {
            overlay.jobs_updateShimmerLayout()
        }
    }

    @objc func jobs_fgOverlay_layoutSubviews() {
        // 注意：交换实现后，这里调用的是“原始 layoutSubviews”
        self.jobs_fgOverlay_layoutSubviews()
        jobs_layoutFGOverlayIfNeeded()
    }
}

public extension UIButton {
    /// 前景图 loading：开启 shimmer（用 overlay，保证 iOS15 configuration / image=nil 时也可见）
    func _jobs_startForegroundShimmerOverlay(targetSize: CGSize) {
        UIButton.jobs_enableForegroundOverlayAutoLayoutUpdatesOnce()
        jobs_fgOverlayTargetSize = targetSize

        let overlay = jobs_getOrCreateFGOverlayView()
        overlay.isHidden = false
        bringSubviewToFront(overlay)

        // ✅ 先开 shimmer，再立刻摆一次 frame：
        // - jobs_startShimmer 里会记录 shimmering 状态
        // - layoutSubviews swizzle 会持续兜底修正 frame/bounds
        overlay.jobs_startShimmer()
        jobs_layoutFGOverlayIfNeeded()

        // 约束布局常在下一帧才生效，多补几次更稳
        DispatchQueue.main.async { [weak self, weak overlay] in
            guard let self, let overlay else { return }
            self.jobs_layoutFGOverlayIfNeeded()
            overlay.jobs_updateShimmerLayout()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self, weak overlay] in
                guard let self, let overlay else { return }
                self.jobs_layoutFGOverlayIfNeeded()
                overlay.jobs_updateShimmerLayout()
            }
        }
    }
    /// 前景图 loading：关闭 shimmer
    func _jobs_stopForegroundShimmerOverlay() {
        guard let overlay = jobs_fgShimmerOverlayView else { return }
        overlay.jobs_stopShimmer()
        overlay.isHidden = true
    }
}
