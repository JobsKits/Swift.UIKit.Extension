//
//  UIView+悬浮.swift
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
// MARK: - 给任意 UIView 增加悬浮能力（可拖拽、吸附、尊重安全区），默认挂在活动窗口。
// 风格：链式 DSL（.suspend / .bySuspend），主线程 API 使用 @MainActor 保障。
// 注意：悬浮 view 使用 frame 驱动，勿再对其添加 AutoLayout 约束。
// 依赖：UIKit + ObjectiveC 运行时
/**【用法示例】
     /// 悬浮（可按需指定 container）
     UIView().bySuspend { cfg in
         cfg.fallbackSize = CGSize(width: 88, height: 44)   // 给标题/副标题更宽松的空间
         cfg.docking = .nearestEdge
         cfg.insets = UIEdgeInsets(top: 20, left: 16, bottom: 34, right: 16)
         cfg.hapticOnDock = true
     }
 */
// MARK: - 悬浮视图@配置
public enum Start {
    case bottomRight, bottomLeft, topRight, topLeft, center
    case point(CGPoint) // 在“可用区域”(仅 safeArea)坐标系内
}

public extension UIView {
    // MARK: - 吸附策略
    enum SuspendDocking {
        case none            // 不吸附
        case nearestEdge     // 吸附最近边
        case nearestCorner   // 吸附最近角
        case auto            // 👈 新增：由 start 推导（默认）
    }
    // MARK: - 悬浮行为配置
    struct SuspendConfig {
        public var start: Start = .bottomRight
        public var container: UIView? = nil
        public var fallbackSize: CGSize = .init(width: 56, height: 56)
        public var initialOrigin: CGPoint? = nil
        public var draggable: Bool = true
        public var docking: SuspendDocking = .auto  // 👈 默认改为 .auto
        public var animated: Bool = true
        public var hapticOnDock: Bool = false
        public var confineInContainer: Bool = true

        public init() {}
        public static var `default`: SuspendConfig { .init() }
    }
}
// MARK: - DSL（Non-mutating 副本风格）
public extension UIView.SuspendConfig {
    /// 工厂：链式外建
    static func dsl(_ build: (inout Self) -> Void) -> Self {
        var cfg = Self.default
        build(&cfg)
        return cfg
    }
    @discardableResult func byContainer(_ v: UIView?) -> Self { var c = self; c.container = v; return c }
    @discardableResult func byFallbackSize(_ v: CGSize) -> Self { var c = self; c.fallbackSize = v; return c }
    @discardableResult func byDocking(_ v: UIView.SuspendDocking) -> Self { var c = self; c.docking = v; return c }
    @discardableResult func byInitialOrigin(_ v: CGPoint?) -> Self { var c = self; c.initialOrigin = v; return c }
    @discardableResult func byDraggable(_ v: Bool) -> Self { var c = self; c.draggable = v; return c }
    @discardableResult func byAnimated(_ v: Bool) -> Self { var c = self; c.animated = v; return c }
    @discardableResult func byHapticOnDock(_ v: Bool) -> Self { var c = self; c.hapticOnDock = v; return c }
    @discardableResult func byConfineInContainer(_ v: Bool) -> Self { var c = self; c.confineInContainer = v; return c }
    @discardableResult func byStart(_ v: Start) -> Self { var c = self; c.start = v; return c }
}
// MARK: - 关联键
private enum SuspendKeys {
    static var configKey: UInt8 = 0
    static var panKey: UInt8 = 0
    static var suspendedKey: UInt8 = 0
}
// MARK: - 主功能
public extension UIView {
    /// 是否已经悬浮（关联对象标记）
    var isSuspended: Bool {
        (objc_getAssociatedObject(self, &SuspendKeys.suspendedKey) as? Bool) ?? false
    }
    /// 解除悬浮：从容器移除并清理内部手势/配置
    @MainActor
    func unsuspend() {
        guard isSuspended else { return }
        if let pan = objc_getAssociatedObject(self, &SuspendKeys.panKey) as? UIPanGestureRecognizer {
            removeGestureRecognizer(pan)
        }
        objc_setAssociatedObject(self, &SuspendKeys.configKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &SuspendKeys.panKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &SuspendKeys.suspendedKey, false, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        removeFromSuperview()
    }
    /// 悬浮：挂到活动窗口或指定容器；支持拖拽/吸附/安全区
    @discardableResult
    @MainActor
    func suspend(_ config: SuspendConfig = .default) -> Self {
        // 1) 保存配置
        objc_setAssociatedObject(self, &SuspendKeys.configKey, config, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        // 2) 容器
        let container: UIView = config.container ?? (UIApplication.jobsKeyWindow() ?? Self._fallbackWindow())
        container.layoutIfNeeded()
        // 3) 添加
        if superview == nil { container.addSubview(self) }
        // 4) 尺寸兜底
        if bounds.size == .zero { frame.size = config.fallbackSize }
        // 5) 初始位置：优先 initialOrigin -> start 推导 -> 右下角保底
        if let origin = config.initialOrigin {
            frame.origin = origin
        } else if frame.origin == .zero {
            let area = Self._availableBounds(in: container) // ✅ 去掉 extraInsets
            frame.origin = _origin(for: config.start, size: frame.size, in: area)
        }
        // 6) 边界夹紧
        if config.confineInContainer { _clampFrameWithinContainer() }
        // 7) 拖拽手势
        if config.draggable {
            let pan: UIPanGestureRecognizer
            if let old = objc_getAssociatedObject(self, &SuspendKeys.panKey) as? UIPanGestureRecognizer {
                pan = old
            } else {
                pan = UIPanGestureRecognizer(target: self, action: #selector(_onPan(_:)))
                addGestureRecognizer(pan)
                objc_setAssociatedObject(self, &SuspendKeys.panKey, pan, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        // 8) 标记
        objc_setAssociatedObject(self, &SuspendKeys.suspendedKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// Builder 版本
    @discardableResult
    @MainActor
    func bySuspend(_ build: (SuspendConfig) -> SuspendConfig) -> Self {
        suspend(build(.default))
    }
}
// MARK: - 私有实现
private extension UIView {
    /// 根据 start & 可用区域推导初始 origin
    func _origin(for start: Start, size: CGSize, in bounds: CGRect) -> CGPoint {
        switch start {
        case .bottomRight:
            return CGPoint(x: bounds.maxX - size.width, y: bounds.maxY - size.height)
        case .bottomLeft:
            return CGPoint(x: bounds.minX, y: bounds.maxY - size.height)
        case .topRight:
            return CGPoint(x: bounds.maxX - size.width, y: bounds.minY)
        case .topLeft:
            return CGPoint(x: bounds.minX, y: bounds.minY)
        case .center:
            return CGPoint(x: bounds.midX - size.width * 0.5, y: bounds.midY - size.height * 0.5)
        case .point(let p):
            // “可用区域”坐标（(0,0) 即 safeArea 左上角）
            return CGPoint(x: bounds.minX + p.x, y: bounds.minY + p.y)
        }
    }
    /// `.auto` → 用 start 推导实际吸附模式
    func _effectiveDocking(_ cfg: UIView.SuspendConfig) -> UIView.SuspendDocking {
        switch cfg.docking {
        case .auto:
            switch cfg.start {
            case .topLeft, .topRight, .bottomLeft, .bottomRight:
                return .nearestCorner        // 角起步 → 吸角
            case .center, .point:
                return .nearestEdge          // 中心/点起步 → 吸边
            }
        default:
            return cfg.docking
        }
    }
    /// 计算吸附目标 origin
    func _snapOrigin(for mode: UIView.SuspendDocking,
                     in container: UIView,
                     cfg: UIView.SuspendConfig,
                     currentFrame f: CGRect) -> CGPoint {
        let b = Self._availableBounds(in: container) // ✅ 去掉 extraInsets
        let w = f.width, h = f.height
        let center = CGPoint(x: f.midX, y: f.midY)

        switch mode {
        case .none:
            return _clamped(f.origin, size: f.size, in: b, clamp: cfg.confineInContainer)

        case .nearestEdge:
            let dLeft   = abs(center.x - b.minX)
            let dRight  = abs(b.maxX - center.x)
            let dTop    = abs(center.y - b.minY)
            let dBottom = abs(b.maxY - center.y)
            let minD = min(dLeft, dRight, dTop, dBottom)
            if minD == dLeft   { return CGPoint(x: b.minX,          y: min(max(b.minY, f.origin.y), b.maxY - h)) }
            if minD == dRight  { return CGPoint(x: b.maxX - w,      y: min(max(b.minY, f.origin.y), b.maxY - h)) }
            if minD == dTop    { return CGPoint(x: min(max(b.minX, f.origin.x), b.maxX - w), y: b.minY) }
            /* minD == dBottom */ return CGPoint(x: min(max(b.minX, f.origin.x), b.maxX - w), y: b.maxY - h)

        case .nearestCorner, .auto:
            let corners: [CGPoint] = [
                CGPoint(x: b.minX,       y: b.minY),
                CGPoint(x: b.maxX - w,   y: b.minY),
                CGPoint(x: b.minX,       y: b.maxY - h),
                CGPoint(x: b.maxX - w,   y: b.maxY - h)
            ]
            var best = corners.first!
            var bestD = CGFloat.greatestFiniteMagnitude
            for c in corners {
                let dx = center.x - (c.x + w * 0.5)
                let dy = center.y - (c.y + h * 0.5)
                let d  = dx*dx + dy*dy
                if d < bestD { bestD = d; best = c }
            }
            return best
        }
    }

    func _clamped(_ origin: CGPoint,
                  size: CGSize,
                  in bounds: CGRect,
                  clamp: Bool) -> CGPoint {
        guard clamp else { return origin }
        let maxX = bounds.maxX - size.width
        let maxY = bounds.maxY - size.height
        return CGPoint(x: min(max(bounds.minX, origin.x), maxX),
                       y: min(max(bounds.minY, origin.y), maxY))
    }

    func _clampFrameWithinContainer() {
        guard
            let cfg = objc_getAssociatedObject(self, &SuspendKeys.configKey) as? UIView.SuspendConfig,
            let container = self.superview
        else { return }
        let b = Self._availableBounds(in: container) // ✅ 去掉 extraInsets
        frame.origin = _clamped(frame.origin, size: frame.size, in: b, clamp: cfg.confineInContainer)
    }
    /// 悬浮视图@手势算法实现
    @objc func _onPan(_ gr: UIPanGestureRecognizer) {
        guard
            let cfg = objc_getAssociatedObject(self, &SuspendKeys.configKey) as? UIView.SuspendConfig,
            let container = self.superview
        else { return }

        switch gr.state {
        case .changed:
            let delta = gr.translation(in: container)
            frame.origin.x += delta.x
            frame.origin.y += delta.y
            gr.setTranslation(.zero, in: container)
            if cfg.confineInContainer { _clampFrameWithinContainer() }

        case .ended, .cancelled, .failed:
            let mode = _effectiveDocking(cfg)
            let target = _snapOrigin(for: mode, in: container, cfg: cfg, currentFrame: frame)
            if cfg.animated {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
                    self.frame.origin = target
                } completion: { _ in
                    if cfg.hapticOnDock {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            } else {
                frame.origin = target
                if cfg.hapticOnDock {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
        default:
            break
        }
    }
    /// 可用区域（仅叠加 safeAreaInsets）
    static func _availableBounds(in container: UIView) -> CGRect {
        let safe = container.safeAreaInsets
        return container.bounds.inset(by: safe)
    }
    /// 悬浮视图@窗口几何
    /// 构造一个兜底窗口（极少会走到这里）
    static func _fallbackWindow() -> UIWindow {
        if #available(iOS 13.0, *),
           let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first {
            let win = UIWindow(windowScene: scene)
                .byFrame(scene.coordinateSpace.bounds)
                .byWindowLevel(.alert + 1)
                .byHidden(false)
            if win.rootViewController == nil {
                win.rootViewController = UIViewController()
            }
            return win
        } else {
            let win = UIWindow(frame: UIScreen.main.bounds)
                .byWindowLevel(.alert + 1)
                .byHidden(false)
            if win.rootViewController == nil {
                win.rootViewController = UIViewController()
            }
            return win
        }
    }
}
