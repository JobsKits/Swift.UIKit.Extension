//
//  UIView.swift
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
import Foundation
import ObjectiveC
import ObjectiveC.runtime
// MARK: 语法糖🍬
extension UIView {
    // MARK: 设置UI
    /// 统一在一个回调里配置 layer
    @discardableResult
    func byLayer(_ config: (CALayer) -> Void) -> Self {
        config(layer)
        return self
    }

    @discardableResult
    func byAddArranged(to stack: UIStackView) -> Self {
        stack.addArrangedSubview(self)
        return self
    }
    
    @discardableResult
    func byBgColor(_ color: UIColor?) -> Self {
        backgroundColor = color
        return self
    }

    @discardableResult
    func byInsertSublayer(_ layer: CALayer, at index: UInt32) -> Self {
        layer.insertSublayer(layer, at: index)
        return self
    }

    @discardableResult
    func byInsertSublayer(_ layer: CALayer, below sibling: CALayer?) -> Self {
        layer.insertSublayer(layer, below: sibling)
        return self
    }

    @discardableResult
    func byInsertSublayer(_ layer: CALayer, above sibling: CALayer?) -> Self {
        layer.insertSublayer(layer, above: sibling)
        return self
    }

    @discardableResult
    func byHidden(_ hidden: Bool) -> Self {
        isHidden = hidden
        return self
    }

    @discardableResult
    func byAlpha(_ a: CGFloat) -> Self {
        alpha = a
        return self
    }
    /// 是否可见：true 显示；false 隐藏（折叠布局）
    @MainActor
    @discardableResult
    func byVisible(_ visible: Bool) -> Self {
        self.byHidden(!visible)
        self.byAlpha(visible ? 1 : 0)
        return self
    }
    /// 统一圆角：按钮走 UIButton.Configuration 方案，其他视图保持原始 layer 逻辑
    @discardableResult
    func byCornerRadius(_ radius: CGFloat) -> Self {
        let r = max(0, radius)
        // === 按钮：套用 byBtnCornerRadius 的实现（maskedCorners=nil, isContinuous=true） ===
        if let btn = self as? UIButton {
            if #available(iOS 15.0, *), var cfg = btn.configuration {
                cfg.cornerStyle = .fixed
                var bg = cfg.background
                bg.cornerRadius = r
                cfg.background = bg
                btn.configuration = cfg
            }
            btn.layer.cornerRadius = r
            if #available(iOS 13.0, *) {
                btn.layer.cornerCurve = .continuous
            }
            // maskedCorners 默认不传（等同 nil），因此这里不改 maskedCorners
            btn.clipsToBounds = (r > 0)
            return self
        }
        // === 非按钮 ===
        self.layer.cornerRadius = r
        return self
    }
    // MARK: 设置Layer
    /// 裁剪超出边界
    @discardableResult
    func byClipsToBounds(_ enabled: Bool = true) -> Self {
        clipsToBounds = enabled
        return self
    }

    @discardableResult
    func byMasksToBounds(_ masksToBounds: Bool) -> Self {
        layer.masksToBounds = masksToBounds
        return self
    }

    @discardableResult
    func byBorderColor(_ color: UIColor?) -> Self {
        layer.borderColor = color?.cgColor   // 传 nil 会清掉边框颜色
         if color == nil { layer.borderWidth = 0 }
        return self
    }

    @discardableResult
    func byZPosition(_ z: CGFloat) -> Self {
        layer.zPosition = z
        return self
    }

    @discardableResult
    func byBorderWidth(_ width: CGFloat) -> Self {
        layer.borderWidth = width
        return self
    }
    // 单项：半径
    @discardableResult
    func byShadowRadius(_ radius: CGFloat) -> Self {
        layer.shadowRadius = radius
        return self
    }

    @discardableResult
    func byShadowColor(_ color: UIColor?) -> Self {
        layer.shadowColor = color?.cgColor
        return self
    }

    @discardableResult
    func byShadowOpacity(_ opacity: Float = 0.0) -> Self {
        layer.shadowOpacity = opacity
        return self
    }

    @discardableResult
    func byShadowOffset(_ offset: CGSize = CGSizeZero) -> Self {
        layer.shadowOffset = offset
        return self
    }
    // MARK: - UIView · Geometry / Transform / Scale / Touch
    /// 几何
    @discardableResult
    func byFrame(_ f: CGRect) -> Self {
        frame = f
        return self
    }

    @discardableResult
    func byBounds(_ b: CGRect) -> Self {
        bounds = b
        return self
    }

    @discardableResult
    func byCenter(_ c: CGPoint) -> Self {
        center = c
        return self
    }
    /// 2D/3D 变换
    @discardableResult
    func byTransform(_ transf: CGAffineTransform) -> Self {
        transform = transf
        return self
    }

    @available(iOS 13.0, *)
    @discardableResult
    func byTransform3D(_ t3d: CATransform3D) -> Self {
        transform3D = t3d
        return self
    }
    /// 缩放因子（渲染分辨率）
    @available(iOS 4.0, *)
    @discardableResult
    func byContentScaleFactor(_ scale: CGFloat) -> Self {
        contentScaleFactor = scale
        return self
    }
    /// 锚点（注意：会影响 frame，需要配合 position/center 调整）
    @available(iOS 16.0, *)
    @discardableResult
    func byAnchorPoint(_ anchor: CGPoint) -> Self {
        anchorPoint = anchor
        return self
    }
    /// 触摸行为
    @discardableResult
    func byMultipleTouchEnabled(_ enabled: Bool) -> Self {
        isMultipleTouchEnabled = enabled
        return self
    }

    @discardableResult
    func byExclusiveTouch(_ enabled: Bool) -> Self {
        isExclusiveTouch = enabled
        return self
    }
    // MARK: 尺寸@绝对设置
    @discardableResult
    func bySize(_ size: CGSize) -> Self {
        frame.size = size
        return self
    }

    @discardableResult
    func bySize(width: CGFloat, height: CGFloat) -> Self {
        frame.size = CGSize(width: width, height: height)
        return self
    }

    @discardableResult
    func byWidth(_ width: CGFloat) -> Self {
        var f = frame; f.size.width = width; frame = f
        return self
    }

    @discardableResult
    func byHeight(_ height: CGFloat) -> Self {
        var f = frame; f.size.height = height; frame = f
        return self
    }
    // MARK: 尺寸@相对偏移叠加
    /// 在当前宽度基础上叠加偏移（正负皆可）
    @discardableResult
    func byWidthOffset(_ delta: CGFloat) -> Self {
        var f = frame; f.size.width += delta; frame = f
        return self
    }
    /// 在当前高度基础上叠加偏移（正负皆可）
    @discardableResult
    func byHeightOffset(_ delta: CGFloat) -> Self {
        var f = frame; f.size.height += delta; frame = f
        return self
    }
    /// 同时对宽高做偏移（正负皆可）
    @discardableResult
    func bySizeOffset(width dw: CGFloat = 0, height dh: CGFloat = 0) -> Self {
        var f = frame; f.size.width += dw; f.size.height += dh; frame = f
        return self
    }
    // MARK: Frame@绝对设置
    @discardableResult
    func byFrame(x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        var f = frame
        if let x = x { f.origin.x = x }
        if let y = y { f.origin.y = y }
        if let w = width { f.size.width = w }
        if let h = height { f.size.height = h }
        frame = f
        return self
    }
    // MARK: Frame@相对偏移叠加
    /// 在当前 x/y 基础上叠加偏移
    @discardableResult
    func byOriginOffset(dx: CGFloat = 0, dy: CGFloat = 0) -> Self {
        var f = frame; f.origin.x += dx; f.origin.y += dy; frame = f
        return self
    }
    @discardableResult
    func byOriginXOffset(_ dx: CGFloat = 0) -> Self {
        var f = frame; f.origin.x += dx; frame = f
        return self
    }
    @discardableResult
    func byOriginYOffset(_ dy: CGFloat = 0) -> Self {
        var f = frame; f.origin.y += dy; frame = f
        return self
    }
    /// 在当前 frame 基础上整体偏移（位置 + 尺寸）
    @discardableResult
    func byFrameOffset(dx: CGFloat = 0, dy: CGFloat = 0, dw: CGFloat = 0, dh: CGFloat = 0) -> Self {
        var f = frame
        f.origin.x += dx; f.origin.y += dy
        f.size.width += dw; f.size.height += dh
        frame = f
        return self
    }
    // MARK: 位置
    @discardableResult
    func byOrigin(_ point: CGPoint) -> Self {
        frame.origin = point
        return self
    }
    /// 在当前中心点基础上叠加偏移
    @discardableResult
    func byCenterOffset(dx: CGFloat = 0, dy: CGFloat = 0) -> Self {
        center = CGPoint(x: center.x + dx, y: center.y + dy)
        return self
    }
    // MARK: - UIView · Subview Hierarchy
    /// 添加子视图（链式）✅ 返回调用者（父视图）
    @discardableResult
    func byAddSubviewRetSuper(_ view: UIView) -> Self {
        addSubview(view)
        return self //
    }
    /// 添加子视图（链式）✅ 返回子视图
    @discardableResult
    func byAddSubviewRetSub<T: UIView>(_ view: T) -> T {
        addSubview(view)
        return view
    }
    /// 在指定层级插入 ✅ 返回调用者（父视图）
    @discardableResult
    func byInsertSubview(_ view: UIView, at index: Int) -> Self {
        insertSubview(view, at: index)
        return self
    }
    /// 在指定层级插入 ✅ 返回子视图
    @discardableResult
    func byInsertSubviewRetSub<T: UIView>(_ view: T, at index: Int) -> T {
        insertSubview(view, at: index)
        return view
    }
    /// 在某视图之下插入 ✅ 返回调用者（父视图）
    @discardableResult
    func byInsertSubview(_ view: UIView, below sibling: UIView) -> Self {
        insertSubview(view, belowSubview: sibling)
        return self
    }
    /// 在某视图之下插入 ✅ 返回子视图
    @discardableResult
    func byInsertSubviewRetSub<T: UIView>(_ view: T, below sibling: UIView) -> T {
        insertSubview(view, belowSubview: sibling)
        return view
    }
    /// 在某视图之上插入 ✅ 返回调用者（父视图）
    @discardableResult
    func byInsertSubview(_ view: UIView, above sibling: UIView) -> Self {
        insertSubview(view, aboveSubview: sibling)
        return self
    }
    /// 在某视图之上插入 ✅ 返回子视图
    @discardableResult
    func byInsertSubviewRetSub<T: UIView>(_ view: T, above sibling: UIView) -> T {
        insertSubview(view, aboveSubview: sibling)
        return view
    }
    /// 交换两个下标的子视图 ✅ 返回调用者（父视图）
    @discardableResult
    func byExchangeSubview(at i: Int, with j: Int) -> Self {
        exchangeSubview(at: i, withSubviewAt: j)
        return self
    }
    /// 置顶 ✅ 返回调用者（父视图）
    @discardableResult
    func byBringToFront(_ view: UIView) -> Self {
        bringSubviewToFront(view)
        return self
    }
    /// 置顶 ✅ 返回子视图
    @discardableResult
    func byBringToFrontRetSub<T: UIView>(_ view: T) -> T {
        bringSubviewToFront(view)
        return view
    }
    /// 置底 ✅ 返回调用者（父视图）
    @discardableResult
    func bySendToBack(_ view: UIView) -> Self {
        sendSubviewToBack(view)
        return self
    }
    /// 置底 ✅ 返回子视图
    @discardableResult
    func bySendToBackRetSub<T: UIView>(_ view: T) -> T {
        sendSubviewToBack(view)
        return view
    }
    /// 移除自身 ✅ 返回调用者（父视图）
    @discardableResult
    func byRemoveFromSuperview() -> Self {
        removeFromSuperview()
        return self
    }
    /// 移除所有子视图（便捷）
    @discardableResult
    func byRemoveAllSubviews() -> Self {
        subviews.forEach { $0.removeFromSuperview() }
        return self
    }
    // MARK: - UIView · Autoresizing / Layout Margins / Safe Area
    /// 是否对子视图做 autoresize
    @discardableResult
    func byAutoresizesSubviews(_ enabled: Bool) -> Self {
        autoresizesSubviews = enabled
        return self
    }
    /// 自伸缩掩码
    @discardableResult
    func byAutoresizingMask(_ mask: UIView.AutoresizingMask) -> Self {
        autoresizingMask = mask
        return self
    }
    /// 传统 layoutMargins
    @available(iOS 8.0, *)
    @discardableResult
    func byLayoutMargins(_ insets: UIEdgeInsets) -> Self {
        layoutMargins = insets
        return self
    }
    /// 方向化的 layoutMargins（更现代）
    @available(iOS 11.0, *)
    @discardableResult
    func byDirectionalLayoutMargins(_ insets: NSDirectionalEdgeInsets) -> Self {
        directionalLayoutMargins = insets
        return self
    }
    /// 是否继承父视图的 layoutMargins
    @available(iOS 8.0, *)
    @discardableResult
    func byPreservesSuperviewLayoutMargins(_ enabled: Bool) -> Self {
        preservesSuperviewLayoutMargins = enabled
        return self
    }
    /// 是否将 safeArea 纳入 layoutMargins 计算
    @available(iOS 11.0, *)
    @discardableResult
    func byInsetsLayoutMarginsFromSafeArea(_ enabled: Bool) -> Self {
        insetsLayoutMarginsFromSafeArea = enabled
        return self
    }
    // MARK: - UIView · Layout Triggers
    /// 标记需要布局
    @discardableResult
    func bySetNeedsLayout() -> Self {
        setNeedsLayout()
        return self
    }
    /// 立即布局
    @discardableResult
    func byLayoutIfNeeded() -> Self {
        layoutIfNeeded()
        return self
    }
    /// 自适应到指定尺寸（仅设置，不触发布局）
    @discardableResult
    func bySizeThatFits(_ size: CGSize) -> Self {
        _ = sizeThatFits(size)
        return self
    }
    /// 自身尺寸适配
    @discardableResult
    func bySizeToFit() -> Self {
        sizeToFit()
        return self
    }
    // MARK: 其他
    @discardableResult
    func byContentMode(_ mode: UIView.ContentMode) -> Self {
        contentMode = mode;
        return self
    }

    @discardableResult
    func byTag(_ T: Int) -> Self {
        tag = T
        return self
    }

    @discardableResult
    func byUserInteractionEnabled(_ enabled: Bool) -> Self {
        isUserInteractionEnabled = enabled
        return self
    }
    /// 手势封装：添加手势以后返回这个手势本身@常用于链式调用
    @discardableResult
    func jobs_addGestureRetView<T: UIGestureRecognizer>(_ gesture: T?) -> Self {
        guard let gesture = gesture else { return self }
        addGestureRecognizer(gesture)
        return self
    }
    /// 手势封装：添加手势以后返回这个手势本身@常用于链式调用
    @discardableResult
    func jobs_addGesture<T: UIGestureRecognizer>(_ gesture: T?) -> T? {
        guard let gesture = gesture else { return nil }
        addGestureRecognizer(gesture)
        return gesture
    }
    /// 刷新UI@标记即可（让系统合帧处理）：适合大多数情况
    @MainActor
    @discardableResult
    func refresh()-> Self{
        setNeedsLayout()  // 下帧再布局
        layoutIfNeeded()  // 立刻完成布局（当前 runloop）
        return self
    }
    /// 刷新UI@标记即可（让系统合帧处理）：适合大多数情况
    @MainActor
    @discardableResult
    func refreshNow() -> Self {
        setNeedsLayout()     // 下帧再布局
        /// 最后同步布局会改变尺寸/路径，应在布局完成后再决定要画什么
        /// 所以把 setNeedsDisplay() 放到 layoutIfNeeded() 之后 更合理
        layoutIfNeeded()     // 立刻完成布局（当前 runloop）
        /// 只当确实重写了 draw(_:) /或者 使用自定义 layerClass 自绘时才需要 setNeedsDisplay()
        setNeedsDisplay()    // 标记（下帧）需要重绘（基于新布局），不是布局
        // 如必须同步把图也画出来（少用，重）：
        // layer.displayIfNeeded()
        return self
    }

    @discardableResult
    public func byActivate() -> Self {
        // 下一帧：让父视图先布局，再让自己重建，避免首帧 bounds==0 的问题
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            superview?.setNeedsLayout()
            superview?.layoutIfNeeded()
            setNeedsLayout()
        };return self
    }
}
/**
 // MARK: - 点击 Tap
 UIView().addGestureRecognizer(
     UITapGestureRecognizer
         .byConfig { gr in
             print("Tap 触发 on: \(String(describing: gr.view))")
         }
         .byTaps(2)                       // 双击
         .byTouches(1)                    // 单指
         .byCancelsTouchesInView(true)
         .byEnabled(true)
         .byName("customTap")
 )

 // MARK: - 长按 LongPress
 UIView().addGestureRecognizer(
     UILongPressGestureRecognizer
         .byConfig { gr in
             if gr.state == .began {
                 print("长按开始")
             } else if gr.state == .ended {
                 print("长按结束")
             }
         }
         .byMinDuration(0.8)              // 最小按压时长
         .byMovement(12)                  // 允许移动距离
         .byTouches(1)                    // 单指
 )

 // MARK: - 拖拽 Pan
 UIView().addGestureRecognizer(
     UIPanGestureRecognizer
         .byConfig { gr in
             let p = (gr as! UIPanGestureRecognizer).translation(in: gr.view)
             if gr.state == .changed {
                 print("拖拽中: \(p)")
             } else if gr.state == .ended {
                 print("拖拽结束")
             }
         }
         .byMinTouches(1)
         .byMaxTouches(2)
         .byCancelsTouchesInView(true)
 )

 // MARK: - 轻扫 Swipe（单方向）
 UIView().addGestureRecognizer(
     UISwipeGestureRecognizer
         .byConfig { _ in
             print("👉 右滑触发")
         }
         .byDirection(.right)
         .byTouches(1)
 )

 // MARK: - 轻扫 Swipe（多方向）
 let swipeContainer = UIView()
 swipeContainer.addGestureRecognizer(
     UISwipeGestureRecognizer
         .byConfig { _ in print("← 左滑") }
         .byDirection(.left)
 )
 swipeContainer.addGestureRecognizer(
     UISwipeGestureRecognizer
         .byConfig { _ in print("→ 右滑") }
         .byDirection(.right)
 )
 swipeContainer.addGestureRecognizer(
     UISwipeGestureRecognizer
         .byConfig { _ in print("↑ 上滑") }
         .byDirection(.up)
 )
 swipeContainer.addGestureRecognizer(
     UISwipeGestureRecognizer
         .byConfig { _ in print("↓ 下滑") }
         .byDirection(.down)
 )

 // MARK: - 捏合 Pinch
 UIView().addGestureRecognizer(
     UIPinchGestureRecognizer
         .byConfig { _ in }
         .byOnScaleChange { gr, scale in
             if gr.state == .changed {
                 print("缩放比例: \(scale)")
             }
         }
         .byScale(1.0)
 )

 // MARK: - 旋转 Rotate
 UIView().addGestureRecognizer(
     UIRotationGestureRecognizer
         .byConfig { _ in }
         .byOnRotationChange { gr, r in
             if gr.state == .changed {
                 print("旋转角度(弧度): \(r)")
             }
         }
         .byRotation(0)
 )
 // MARK: - 直接设置手势（已锚定视图）
 let views = UIView()
     .addTapAction { gr in
         print("点击 \(gr.view!)")
     }
     .addLongPressAction { gr in
         if gr.state == .began { print("长按开始") }
     }
     .addPanAction { gr in
         let p = (gr as! UIPanGestureRecognizer).translation(in: gr.view)
         print("拖拽中: \(p)")
     }
     .addPinchAction { gr in
         let scale = (gr as! UIPinchGestureRecognizer).scale
         print("缩放比例：\(scale)")
     }
     .addRotationAction { gr in
         let rotation = (gr as! UIRotationGestureRecognizer).rotation
         print("旋转角度：\(rotation)")
     }

 // MARK: - 在已有的手势触发事件里面新增手势行为
 UIView().addGestureRecognizer(UISwipeGestureRecognizer()
     .byDirection(.left)
     .byAction { gr in print("左滑 \(gr.view!)") })

 // MARK: - 多个方向的 swipe 并存
 // 同一 view 上同时添加四个方向的 swipe
 let idL = view.addSwipeActionMulti(direction: .left)  { gr in print("←") }
 let idR = view.addSwipeActionMulti(direction: .right) { gr in print("→") }
 let idU = view.addSwipeActionMulti(direction: .up)    { gr in print("↑") }
 let idD = view.addSwipeActionMulti(direction: .down)  { gr in print("↓") }

 // 指定 id，方便链式与管理
 view.addSwipeActionMulti(use: "swipe.left", direction: .left) { _ in }
     .addSwipeActionMulti(use: "swipe.right", direction: .right) { _ in }

 // 精确移除某一个
 view.removeSwipeActionMulti(id: idL)
 // 或批量移除该类手势
 view.removeAllSwipeActionsMulti()
 */
// ================================== UIView + 手势 DSL（全量、兼容） ==================================
public extension UIView {
    // 每个手势类型独立 key（同时用于“view->gesture”和“gesture->box”）
    private struct GestureKeys {
        static var tapKey: UInt8 = 0
        static var longKey: UInt8 = 0
        static var panKey: UInt8 = 0
        static var swipeKey: UInt8 = 0
        static var pinchKey: UInt8 = 0
        static var rotateKey: UInt8 = 0
    }
    // MARK: - 手势通用闭包盒子
    private final class _GestureActionBox {
        let action: (UIGestureRecognizer) -> Void
        init(_ action: @escaping (UIGestureRecognizer) -> Void) { self.action = action }
    }
    // MARK: - Tap（点击）
    /// 新接口：带 gesture；兼容链式配置
    @discardableResult
    func addTapAction(
        taps: Int = 1,
        cancelsTouchesInView: Bool = true,
        requiresExclusiveTouchType: Bool = false,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        isUserInteractionEnabled = true

        if let old = objc_getAssociatedObject(self, &GestureKeys.tapKey) as? UITapGestureRecognizer {
            removeGestureRecognizer(old)
        }

        let tap = jobs_addGesture(
            UITapGestureRecognizer
                .byConfig { gr in
                    (objc_getAssociatedObject(gr, &GestureKeys.tapKey) as? _GestureActionBox)?.action(gr)
                    print("Tap 触发 on: \(String(describing: gr.view))")
                }
                .byTaps(taps)                       // 双击
                .byTouches(1)                       // 单指
                .byCancelsTouchesInView(cancelsTouchesInView)
                .byRequiresExclusiveTouchType(requiresExclusiveTouchType)
                .byEnabled(true)
                .byName("customTap"))!

        objc_setAssociatedObject(self, &GestureKeys.tapKey, tap, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(tap, &GestureKeys.tapKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口：无参数（向下兼容）
    @discardableResult
    func addTapAction(_ action: @escaping () -> Void) -> Self {
        addTapAction { _ in action() }
    }
    func removeTapAction() {
        if let g = objc_getAssociatedObject(self, &GestureKeys.tapKey) as? UITapGestureRecognizer {
            removeGestureRecognizer(g)
        }
        objc_setAssociatedObject(self, &GestureKeys.tapKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }
    // MARK: - LongPress（长按）
    @discardableResult
    func addLongPressAction(
        minimumPressDuration: TimeInterval = 0.5,
        allowableMovement: CGFloat = 10,
        numberOfTouchesRequired: Int = 1,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        isUserInteractionEnabled = true

        if let old = objc_getAssociatedObject(self, &GestureKeys.longKey) as? UILongPressGestureRecognizer {
            removeGestureRecognizer(old)
        }

        let long = jobs_addGesture(UILongPressGestureRecognizer
            .byConfig { gr in
                (objc_getAssociatedObject(gr, &GestureKeys.longKey) as? _GestureActionBox)?.action(gr)
            }
            .byMinDuration(minimumPressDuration)              // 最小按压时长
            .byMovement(allowableMovement)                    // 允许移动距离
            .byTouches(numberOfTouchesRequired)               // 单指
        )!

        objc_setAssociatedObject(self, &GestureKeys.longKey, long, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(long, &GestureKeys.longKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addLongPressAction(_ action: @escaping () -> Void) -> Self {
        addLongPressAction { _ in action() }
    }
    func removeLongPressAction() {
        if let g = objc_getAssociatedObject(self, &GestureKeys.longKey) as? UILongPressGestureRecognizer {
            removeGestureRecognizer(g)
        }
        objc_setAssociatedObject(self, &GestureKeys.longKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }
    // MARK: - Pan（拖拽）
    @discardableResult
    func addPanAction(
        minimumNumberOfTouches: Int = 1,
        maximumNumberOfTouches: Int = Int.max,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        isUserInteractionEnabled = true

        if let old = objc_getAssociatedObject(self, &GestureKeys.panKey) as? UIPanGestureRecognizer {
            removeGestureRecognizer(old)
        }

        let pan = jobs_addGesture(UIPanGestureRecognizer
            .byConfig { sender in
                (objc_getAssociatedObject(sender, &GestureKeys.panKey) as? _GestureActionBox)?.action(sender)
            }
            .byMinTouches(minimumNumberOfTouches)
            .byMaxTouches(maximumNumberOfTouches)
            .byCancelsTouchesInView(true))!

        objc_setAssociatedObject(self, &GestureKeys.panKey, pan, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(pan, &GestureKeys.panKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addPanAction(_ action: @escaping () -> Void) -> Self {
        addPanAction { _ in action() }
    }
    func removePanAction() {
        if let g = objc_getAssociatedObject(self, &GestureKeys.panKey) as? UIPanGestureRecognizer {
            removeGestureRecognizer(g)
        }
        objc_setAssociatedObject(self, &GestureKeys.panKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }
    // MARK: - Swipe（轻扫）
    @discardableResult
    func addSwipeAction(
        direction: UISwipeGestureRecognizer.Direction = .right,
        numberOfTouchesRequired: Int = 1,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        isUserInteractionEnabled = true

        if let old = objc_getAssociatedObject(self, &GestureKeys.swipeKey) as? UISwipeGestureRecognizer {
            removeGestureRecognizer(old)
        }

        let swipe = jobs_addGesture(UISwipeGestureRecognizer
            .byConfig { sender in
                print("👉 右滑触发")
                (objc_getAssociatedObject(sender, &GestureKeys.swipeKey) as? _GestureActionBox)?.action(sender)
            }
            .byDirection(direction)
            .byTouches(numberOfTouchesRequired))!

        objc_setAssociatedObject(self, &GestureKeys.swipeKey, swipe, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(swipe, &GestureKeys.swipeKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addSwipeAction(_ action: @escaping () -> Void) -> Self {
        addSwipeAction { _ in action() }
    }
    func removeSwipeAction() {
        if let g = objc_getAssociatedObject(self, &GestureKeys.swipeKey) as? UISwipeGestureRecognizer {
            removeGestureRecognizer(g)
        }
        objc_setAssociatedObject(self, &GestureKeys.swipeKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }
    // MARK: - Pinch（捏合缩放）
    @discardableResult
    func addPinchAction(_ action: @escaping (UIGestureRecognizer) -> Void) -> Self {
        isUserInteractionEnabled = true

        if let old = objc_getAssociatedObject(self, &GestureKeys.pinchKey) as? UIPinchGestureRecognizer {
            removeGestureRecognizer(old)
        }

        let pinch = jobs_addGesture(UIPinchGestureRecognizer
            .byConfig { _ in }
            .byOnScaleChange { sender, scale in
                (objc_getAssociatedObject(sender, &GestureKeys.pinchKey) as? _GestureActionBox)?.action(sender)
            }
        )!

        objc_setAssociatedObject(self, &GestureKeys.pinchKey, pinch, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(pinch, &GestureKeys.pinchKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addPinchAction(_ action: @escaping () -> Void) -> Self {
        addPinchAction { _ in action() }
    }
    func removePinchAction() {
        if let g = objc_getAssociatedObject(self, &GestureKeys.pinchKey) as? UIPinchGestureRecognizer {
            removeGestureRecognizer(g)
        }
        objc_setAssociatedObject(self, &GestureKeys.pinchKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }
    // MARK: - Rotation（旋转）
    @discardableResult
    func addRotationAction(_ action: @escaping (UIGestureRecognizer) -> Void) -> Self {
        isUserInteractionEnabled = true

        if let old = objc_getAssociatedObject(self, &GestureKeys.rotateKey) as? UIRotationGestureRecognizer {
            removeGestureRecognizer(old)
        }

        let rotate = jobs_addGesture(UIRotationGestureRecognizer
            .byConfig { _ in }
            .byOnRotationChange { sender, r in
                (objc_getAssociatedObject(sender, &GestureKeys.rotateKey) as? _GestureActionBox)?.action(sender)
            })!

        objc_setAssociatedObject(self, &GestureKeys.rotateKey, rotate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(rotate, &GestureKeys.rotateKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addRotationAction(_ action: @escaping () -> Void) -> Self {
        addRotationAction { _ in action() }
    }
    @objc private func _gestureHandleRotate(_ sender: UIRotationGestureRecognizer) {
        (objc_getAssociatedObject(sender, &GestureKeys.rotateKey) as? _GestureActionBox)?.action(sender)
    }
    func removeRotationAction() {
        if let g = objc_getAssociatedObject(self, &GestureKeys.rotateKey) as? UIRotationGestureRecognizer {
            removeGestureRecognizer(g)
        }
        objc_setAssociatedObject(self, &GestureKeys.rotateKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }
    // MARK: - 便利方法：一次性清理
    func removeAllGestureActions() {
        removeTapAction()
        removeLongPressAction()
        removePanAction()
        removeSwipeAction()
        removePinchAction()
        removeRotationAction()
    }
}
/**
     // 同一 view 上同时添加四个方向的 swipe
     let idL = view.addSwipeActionMulti(direction: .left)  { gr in print("←") }
     let idR = view.addSwipeActionMulti(direction: .right) { gr in print("→") }
     let idU = view.addSwipeActionMulti(direction: .up)    { gr in print("↑") }
     let idD = view.addSwipeActionMulti(direction: .down)  { gr in print("↓") }

     // 指定 id，方便链式与管理
     view.addSwipeActionMulti(use: "swipe.left", direction: .left) { _ in }
         .addSwipeActionMulti(use: "swipe.right", direction: .right) { _ in }

     // 精确移除某一个
     view.removeSwipeActionMulti(id: idL)
     // 或批量移除该类手势
     view.removeAllSwipeActionsMulti()
 */
// MARK: - 多个方向的 swipe 并存
public extension UIView {
    // 为每种手势维护一个 “id -> gesture” 的字典
    private struct GestureMultiKeys {
        static var tapMap:    UInt8 = 0
        static var longMap:   UInt8 = 0
        static var panMap:    UInt8 = 0
        static var swipeMap:  UInt8 = 0
        static var pinchMap:  UInt8 = 0
        static var rotateMap: UInt8 = 0
    }
    // 取/存 通用 map（view 维度）
    private func _grMap(for key: UnsafeRawPointer) -> [String: UIGestureRecognizer] {
        (objc_getAssociatedObject(self, key) as? [String: UIGestureRecognizer]) ?? [:]
    }
    private func _setGrMap(_ map: [String: UIGestureRecognizer], for key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, map, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    // MARK: - Tap（多实例）
    /// 返回生成的 id（便于后续精确移除）
    @discardableResult
    func addTapActionMulti(
        id: String = UUID().uuidString,
        taps: Int = 1,
        cancelsTouchesInView: Bool = true,
        requiresExclusiveTouchType: Bool = false,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> String {
        isUserInteractionEnabled = true

        var map = _grMap(for: &GestureMultiKeys.tapMap)
        // 如果同 id 已存在，先移除再覆盖
        if let old = map[id] as? UITapGestureRecognizer { removeGestureRecognizer(old) }
        let gr = jobs_addGesture(
            UITapGestureRecognizer
                .byConfig { gr in
                    (objc_getAssociatedObject(gr, &GestureKeys.tapKey) as? _GestureActionBox)?.action(gr)
                    print("Tap 触发 on: \(String(describing: gr.view))")
                }
                .byTaps(taps)                       // 双击
                .byTouches(1)                       // 单指
                .byCancelsTouchesInView(cancelsTouchesInView)
                .byRequiresExclusiveTouchType(requiresExclusiveTouchType)
                .byEnabled(true)
                .byName("customTap"))!
        // 复用单实例版里“gesture -> box”的关联键（每个 recognizer 独立存一份）
        objc_setAssociatedObject(gr, &GestureKeys.tapKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        map[id] = gr
        _setGrMap(map, for: &GestureMultiKeys.tapMap)
        return id
    }
    /// 提供一个便于链式的重载：自己指定 id，可继续链式
    @discardableResult
    func addTapActionMulti(
        use id: String,
        taps: Int = 1,
        cancelsTouchesInView: Bool = true,
        requiresExclusiveTouchType: Bool = false,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        _ = addTapActionMulti(id: id, taps: taps, cancelsTouchesInView: cancelsTouchesInView, requiresExclusiveTouchType: requiresExclusiveTouchType, action)
        return self
    }

    func removeTapActionMulti(id: String) {
        var map = _grMap(for: &GestureMultiKeys.tapMap)
        if let g = map[id] {
            removeGestureRecognizer(g)
            map.removeValue(forKey: id)
            _setGrMap(map, for: &GestureMultiKeys.tapMap)
        }
    }
    func removeAllTapActionsMulti() {
        var map = _grMap(for: &GestureMultiKeys.tapMap)
        map.values.forEach { removeGestureRecognizer($0) }
        map.removeAll()
        _setGrMap(map, for: &GestureMultiKeys.tapMap)
    }
    // MARK: - LongPress（多实例）
    @discardableResult
    func addLongPressActionMulti(
        id: String = UUID().uuidString,
        minimumPressDuration: TimeInterval = 0.5,
        allowableMovement: CGFloat = 10,
        numberOfTouchesRequired: Int = 1,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> String {
        isUserInteractionEnabled = true

        var map = _grMap(for: &GestureMultiKeys.longMap)
        if let old = map[id] as? UILongPressGestureRecognizer { removeGestureRecognizer(old) }

        let gr = jobs_addGesture(UILongPressGestureRecognizer
            .byConfig { gr in
                (objc_getAssociatedObject(gr, &GestureKeys.longKey) as? _GestureActionBox)?.action(gr)
            }
            .byMinDuration(minimumPressDuration)              // 最小按压时长
            .byMovement(allowableMovement)                    // 允许移动距离
            .byTouches(numberOfTouchesRequired)               // 单指
        )!

        objc_setAssociatedObject(gr, &GestureKeys.longKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        map[id] = gr
        _setGrMap(map, for: &GestureMultiKeys.longMap)
        return id
    }
    @discardableResult
    func addLongPressActionMulti(
        use id: String,
        minimumPressDuration: TimeInterval = 0.5,
        allowableMovement: CGFloat = 10,
        numberOfTouchesRequired: Int = 1,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        _ = addLongPressActionMulti(id: id,
                                    minimumPressDuration: minimumPressDuration,
                                    allowableMovement: allowableMovement,
                                    numberOfTouchesRequired: numberOfTouchesRequired,
                                    action)
        return self
    }
    func removeLongPressActionMulti(id: String) {
        var map = _grMap(for: &GestureMultiKeys.longMap)
        if let g = map[id] {
            removeGestureRecognizer(g); map.removeValue(forKey: id)
            _setGrMap(map, for: &GestureMultiKeys.longMap)
        }
    }
    func removeAllLongPressActionsMulti() {
        var map = _grMap(for: &GestureMultiKeys.longMap)
        map.values.forEach { removeGestureRecognizer($0) }
        map.removeAll(); _setGrMap(map, for: &GestureMultiKeys.longMap)
    }
    // MARK: - Pan（多实例）
    @discardableResult
    func addPanActionMulti(
        id: String = UUID().uuidString,
        minimumNumberOfTouches: Int = 1,
        maximumNumberOfTouches: Int = Int.max,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> String {
        isUserInteractionEnabled = true

        var map = _grMap(for: &GestureMultiKeys.panMap)
        if let old = map[id] as? UIPanGestureRecognizer { removeGestureRecognizer(old) }

        let gr = jobs_addGesture(UIPanGestureRecognizer
            .byConfig { sender in
                (objc_getAssociatedObject(sender, &GestureKeys.panKey) as? _GestureActionBox)?.action(sender)
            }
            .byMinTouches(minimumNumberOfTouches)
            .byMaxTouches(maximumNumberOfTouches)
            .byCancelsTouchesInView(true))!

        objc_setAssociatedObject(gr, &GestureKeys.panKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        map[id] = gr
        _setGrMap(map, for: &GestureMultiKeys.panMap)
        return id
    }
    @discardableResult
    func addPanActionMulti(
        use id: String,
        minimumNumberOfTouches: Int = 1,
        maximumNumberOfTouches: Int = Int.max,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        _ = addPanActionMulti(id: id,
                              minimumNumberOfTouches: minimumNumberOfTouches,
                              maximumNumberOfTouches: maximumNumberOfTouches,
                              action)
        return self
    }
    func removePanActionMulti(id: String) {
        var map = _grMap(for: &GestureMultiKeys.panMap)
        if let g = map[id] {
            removeGestureRecognizer(g); map.removeValue(forKey: id)
            _setGrMap(map, for: &GestureMultiKeys.panMap)
        }
    }
    func removeAllPanActionsMulti() {
        var map = _grMap(for: &GestureMultiKeys.panMap)
        map.values.forEach { removeGestureRecognizer($0) }
        map.removeAll(); _setGrMap(map, for: &GestureMultiKeys.panMap)
    }
    // MARK: - Swipe（多实例）
    @discardableResult
    func addSwipeActionMulti(
        id: String = UUID().uuidString,
        direction: UISwipeGestureRecognizer.Direction = .right,
        numberOfTouchesRequired: Int = 1,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> String {
        isUserInteractionEnabled = true

        var map = _grMap(for: &GestureMultiKeys.swipeMap)
        if let old = map[id] as? UISwipeGestureRecognizer { removeGestureRecognizer(old) }

        let gr = jobs_addGesture(UISwipeGestureRecognizer
            .byConfig { sender in
                print("👉 右滑触发")
                (objc_getAssociatedObject(sender, &GestureKeys.swipeKey) as? _GestureActionBox)?.action(sender)
            }
            .byDirection(direction)
            .byTouches(numberOfTouchesRequired))!

        objc_setAssociatedObject(gr, &GestureKeys.swipeKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        map[id] = gr
        _setGrMap(map, for: &GestureMultiKeys.swipeMap)
        return id
    }
    @discardableResult
    func addSwipeActionMulti(
        use id: String,
        direction: UISwipeGestureRecognizer.Direction = .right,
        numberOfTouchesRequired: Int = 1,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        _ = addSwipeActionMulti(id: id, direction: direction, numberOfTouchesRequired: numberOfTouchesRequired, action)
        return self
    }
    func removeSwipeActionMulti(id: String) {
        var map = _grMap(for: &GestureMultiKeys.swipeMap)
        if let g = map[id] {
            removeGestureRecognizer(g); map.removeValue(forKey: id)
            _setGrMap(map, for: &GestureMultiKeys.swipeMap)
        }
    }
    func removeAllSwipeActionsMulti() {
        var map = _grMap(for: &GestureMultiKeys.swipeMap)
        map.values.forEach { removeGestureRecognizer($0) }
        map.removeAll(); _setGrMap(map, for: &GestureMultiKeys.swipeMap)
    }
    // MARK: - Pinch（多实例）
    @discardableResult
    func addPinchActionMulti(
        id: String = UUID().uuidString,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> String {
        isUserInteractionEnabled = true

        var map = _grMap(for: &GestureMultiKeys.pinchMap)
        if let old = map[id] as? UIPinchGestureRecognizer { removeGestureRecognizer(old) }

        let gr = jobs_addGesture(UIPinchGestureRecognizer
            .byConfig { _ in }
            .byOnScaleChange { sender, scale in
                (objc_getAssociatedObject(sender, &GestureKeys.pinchKey) as? _GestureActionBox)?.action(sender)
            }
        )!

        objc_setAssociatedObject(gr, &GestureKeys.pinchKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        map[id] = gr
        _setGrMap(map, for: &GestureMultiKeys.pinchMap)
        return id
    }
    @discardableResult
    func addPinchActionMulti(use id: String, _ action: @escaping (UIGestureRecognizer) -> Void) -> Self {
        _ = addPinchActionMulti(id: id, action)
        return self
    }
    func removePinchActionMulti(id: String) {
        var map = _grMap(for: &GestureMultiKeys.pinchMap)
        if let g = map[id] {
            removeGestureRecognizer(g); map.removeValue(forKey: id)
            _setGrMap(map, for: &GestureMultiKeys.pinchMap)
        }
    }
    func removeAllPinchActionsMulti() {
        var map = _grMap(for: &GestureMultiKeys.pinchMap)
        map.values.forEach { removeGestureRecognizer($0) }
        map.removeAll(); _setGrMap(map, for: &GestureMultiKeys.pinchMap)
    }
    // MARK: - Rotation（多实例）
    @discardableResult
    func addRotationActionMulti(
        id: String = UUID().uuidString,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> String {
        isUserInteractionEnabled = true

        var map = _grMap(for: &GestureMultiKeys.rotateMap)
        if let old = map[id] as? UIRotationGestureRecognizer { removeGestureRecognizer(old) }

        let gr = UIRotationGestureRecognizer(target: self, action: #selector(_gestureHandleRotate(_:)))
        addGestureRecognizer(gr)

        objc_setAssociatedObject(gr, &GestureKeys.rotateKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        map[id] = gr
        _setGrMap(map, for: &GestureMultiKeys.rotateMap)
        return id
    }
    @discardableResult
    func addRotationActionMulti(use id: String, _ action: @escaping (UIGestureRecognizer) -> Void) -> Self {
        _ = addRotationActionMulti(id: id, action)
        return self
    }
    func removeRotationActionMulti(id: String) {
        var map = _grMap(for: &GestureMultiKeys.rotateMap)
        if let g = map[id] {
            removeGestureRecognizer(g); map.removeValue(forKey: id)
            _setGrMap(map, for: &GestureMultiKeys.rotateMap)
        }
    }
    func removeAllRotationActionsMulti() {
        var map = _grMap(for: &GestureMultiKeys.rotateMap)
        map.values.forEach { removeGestureRecognizer($0) }
        map.removeAll(); _setGrMap(map, for: &GestureMultiKeys.rotateMap)
    }
}

public extension UIView {
    func _allSubviews() -> [UIView] { subviews + subviews.flatMap { $0._allSubviews() } }
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
        }
        return result
    }
    /// 向上寻找满足条件的祖先
    func _firstAncestor(where predicate: (UIView) -> Bool) -> UIView? {
        var p = superview
        while let v = p {
            if predicate(v) { return v }
            p = v.superview
        }
        return nil
    }
}
// MARK: - UIView.keyboardHeight (Observable<CGFloat>)
#if canImport(RxSwift) && canImport(RxCocoa)
import RxSwift
import RxCocoa
private var kKeyboardHeightKey: UInt8 = 0
public extension UIView {
    /// 监听当前视图所处界面的键盘可见高度（单位：pt）
    /// - 说明：
    ///   - 当键盘显示/隐藏/高度变化时发出事件
    ///   - 已扣除 `safeAreaInsets.bottom`，拿到的是“真实遮挡高度”
    ///   - 已做去重（distinctUntilChanged）与主线程派发
    var keyboardHeight: Observable<CGFloat> {
        // 缓存：确保同一视图多次访问用同一个 Observable
        if let cached = objc_getAssociatedObject(self, &kKeyboardHeightKey) as? Observable<CGFloat> {
            return cached
        }
        // 通知源
        let willShow  = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
        let willHide  = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
        let willChangeFrame = NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification)

        // 统一拿键盘 endFrame → 计算与当前视图的遮挡高度
        func height(from note: Notification) -> CGFloat {
            guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return 0
            }
            // 键盘是屏幕坐标，这里转到当前视图的坐标系，计算遮挡
            let window = UIApplication.jobsKeyWindow()
            let endInView: CGRect = {
                if let win = window {
                    let rInWin = win.convert(frame, from: nil)
                    return self.convert(rInWin, from: win)
                } else {
                    // 没有 window 时退化处理
                    return self.convert(frame, from: nil)
                }
            }()
            // 视图底部到键盘顶部的重叠高度
            let overlap = max(0, self.bounds.maxY - endInView.minY)
            // 扣除底部安全区，得到真正需要上移/留白的高度
            let adjusted = max(0, overlap - self.safeAreaInsets.bottom)
            return adjusted.rounded(.towardZero) // 避免细微浮点波动
        }
        // 三类事件合并：
        // - show / changeFrame：计算高度
        // - hide：高度归零
        let showOrChange = Observable
            .merge(willShow, willChangeFrame)
            .map { height(from: $0) }

        let hide = willHide
            .map { _ in CGFloat(0) }

        let stream = Observable
            .merge(showOrChange, hide)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            // 保证多订阅者共享一个上游订阅；最后一个订阅者取消后自动释放
            .share(replay: 1, scope: .whileConnected)

        objc_setAssociatedObject(self, &kKeyboardHeightKey, stream, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return stream
    }
}
#endif
// MARK: - SnapKit
#if canImport(SnapKit)
import SnapKit
/// SnapKit 语法糖🍬
// 存的就是这个类型
public typealias JobsConstraintClosure = (_ make: ConstraintMaker) -> Void
private enum _JobsAssocKeys {
    static var addClosureKey: UInt8 = 0
}
public extension UIView {
    var jobsAddConstraintsClosure: JobsConstraintClosure? {
        get {
            objc_getAssociatedObject(self, &_JobsAssocKeys.addClosureKey) as? JobsConstraintClosure
        }
        set {
            // 闭包推荐 COPY 语义
            objc_setAssociatedObject(self,
                                     &_JobsAssocKeys.addClosureKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    // MARK: - 存储约束
    @discardableResult
    func byAddConstraintsClosure(_ closure: ((_ make: ConstraintMaker) -> Void)? = nil) -> Self {
        if let closure {
            self.jobsAddConstraintsClosure = closure
        };return self
    }
    // MARK: - 添加约束
    @discardableResult
    func byAdd(_ closure: ((_ make: ConstraintMaker) -> Void)? = nil) -> Self {
        if let closure {
            self.byAddConstraintsClosure(closure)
            self.snp.makeConstraints(closure)
        };return self
    }
    // MARK: - 添加到父视图
    @discardableResult
    func byAddTo(_ superview: UIView) -> Self {
        superview.addSubview(self)
        return self
    }

    @discardableResult
    func byAddTo(_ superview: UIView,
                 _ closure: ((_ make: ConstraintMaker) -> Void)? = nil) -> Self {
        superview.addSubview(self)
        byAdd(closure)
        return self
    }
    // MARK: - 链式 makeConstraints
    @discardableResult
    func byMakeConstraints(_ closure: @escaping (_ make: ConstraintMaker) -> Void) -> Self {
        self.byAddConstraintsClosure(closure)
        self.snp.makeConstraints(closure)
        return self
    }
    // MARK: - 链式 remakeConstraints
    @discardableResult
    func byRemakeConstraints(_ closure: @escaping (_ make: ConstraintMaker) -> Void) -> Self {
        self.byAddConstraintsClosure(closure)
        self.snp.remakeConstraints(closure)
        return self
    }
    // MARK: - 链式 updateConstraints
    @discardableResult
    func byUpdateConstraints(_ closure: @escaping (_ make: ConstraintMaker) -> Void) -> Self {
        self.byAddConstraintsClosure(closure)
        self.snp.updateConstraints(closure)
        return self
    }
    // MARK: - 链式 removeConstraints
    @discardableResult
    func byRemoveConstraints() -> Self {
        self.byAddConstraintsClosure(nil)
        self.snp.removeConstraints()
        return self
    }
}
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
// MARK: - 公共类型@右上角角标
public enum RTBadgeContent {
    case text(String)
    case attributed(NSAttributedString)
    case custom(UIView)
}

public struct RTBadgeConfig {
    public var backgroundColor: UIColor = .systemRed
    public var textColor: UIColor = .white
    public var font: UIFont = .systemFont(ofSize: 12, weight: .semibold)
    /// nil = 自动按高度一半做胶囊圆角；给值则为固定圆角
    public var cornerRadius: CGFloat? = nil
    public var insets: UIEdgeInsets = .init(top: 2, left: 6, bottom: 2, right: 6)
    /// (+x 向右, +y 向下)。右上角常用：(-4, 4)
    public var offset: UIOffset = .init(horizontal: -4, vertical: 4)
    public var maxWidth: CGFloat = 200
    public var borderColor: UIColor? = nil
    public var borderWidth: CGFloat = 0
    public var shadowColor: UIColor? = nil
    public var shadowRadius: CGFloat = 0
    public var shadowOpacity: Float = 0
    public var shadowOffset: CGSize = .zero
    public var zIndex: CGFloat = 9999
    public init() {}
}

public extension RTBadgeConfig {
    @discardableResult func byOffset(_ v: UIOffset = .init(horizontal: -6, vertical: 6)) -> Self { var c=self; c.offset=v; return c }
    @discardableResult func byInsets(_ v: UIEdgeInsets = .init(top: 2, left: 6, bottom: 2, right: 6)) -> Self { var c=self; c.insets=v; return c }
    @discardableResult func byInset(_ v: UIEdgeInsets = .init(top: 2, left: 6, bottom: 2, right: 6)) -> Self { var c=self; c.insets=v; return c }
    @discardableResult func byBgColor(_ v: UIColor = .systemRed) -> Self { var c=self; c.backgroundColor=v; return c }
    @discardableResult func byTextColor(_ v: UIColor = .white) -> Self { var c=self; c.textColor=v; return c }
    @discardableResult func byFont(_ v: UIFont = .systemFont(ofSize: 11, weight: .bold)) -> Self { var c=self; c.font=v; return c }
    @discardableResult func byCornerRadius(_ v: CGFloat? = nil) -> Self { var c=self; c.cornerRadius=v; return c }
    @discardableResult func byBorder(color: UIColor? = nil, width: CGFloat = 0) -> Self { var c=self; c.borderColor=color; c.borderWidth=width; return c }
    @discardableResult func byMaxWidth(_ v: CGFloat = 200) -> Self { var c=self; c.maxWidth=v; return c }
    @discardableResult func byZIndex(_ v: CGFloat = 9999) -> Self { var c=self; c.zIndex=v; return c }
    @discardableResult
    func byShadow(color: UIColor? = UIColor.black.withAlphaComponent(0.25),
                  radius: CGFloat = 2,
                  opacity: Float = 0.6,
                  offset: CGSize = .init(width: 0, height: 1)) -> Self {
        var c = self
        c.shadowColor = color
        c.shadowRadius = radius
        c.shadowOpacity = opacity
        c.shadowOffset = offset
        return c
    }
}

public extension UIView {
    /// 右上角角标：添加/更新，内容自定义（SnapKit 约束）
    @discardableResult
    func byCornerBadge(_ content: RTBadgeContent,
                       build: ((RTBadgeConfig) -> RTBadgeConfig)? = nil) -> Self {
        assert(Thread.isMainThread, "UI must be updated on main thread")
        var cfg = RTBadgeConfig()
        if let build = build { cfg = build(cfg) }

        let container = ensureRTBadgeContainer()
        if container.superview !== self { addSubview(container) }

        container.byUserInteractionEnabled(false)
            .byMasksToBounds(false)
            .byBorderColor(cfg.borderColor)
            .byZPosition(cfg.zIndex)
            .byBgColor(cfg.backgroundColor)
            .byBorderWidth(cfg.borderWidth)

        if let sc = cfg.shadowColor {
            container.byShadowColor(sc)
                .byShadowRadius(cfg.shadowRadius)
                .byShadowOpacity(cfg.shadowOpacity)
                .byShadowOffset(cfg.shadowOffset)
        } else {
            container.byShadowOpacity(cfg.shadowOpacity)
        }
        /// 内容
        install(content, into: container, config: cfg)
        /// 右上角定位（SnapKit）
        installRTBadgeConstraints(container: container,
                                  offset: cfg.offset,
                                  maxWidth: cfg.maxWidth)
        /// 圆角
        if let r = cfg.cornerRadius {
            container.autoCapsule = false
            container.byShadowRadius(r)
        } else {
            container.autoCapsule = true // 在 layoutSubviews 按高度一半
            container.refresh()
        }

        return self
    }
    /// 右上角角标：快捷文本
    @discardableResult
    func byCornerBadgeText(_ text: String,
                           build: ((RTBadgeConfig) -> RTBadgeConfig)? = nil) -> Self {
        byCornerBadge(.text(text), build: build)
    }
    /// 右上角小红点（纯圆）
    @discardableResult
    func byCornerDot(diameter: CGFloat = 8,
                     offset: UIOffset = .init(horizontal: -4, vertical: 4),
                     color: UIColor = .systemRed) -> Self {
        return byCornerBadge(.custom(UIView()
            .byBgColor(color)
            .byCornerRadius(diameter / 2)
            .byAdd({ make in
                make.width.height.equalTo(diameter)
            }))) { cfg in
                cfg.byInset(.zero)
                    .byCornerRadius(diameter / 2)
                    .byOffset(offset)
                    .byBgColor(.clear)
                    .byBorder(color: nil, width: 0)
                    .byShadow(color: nil)
        }
    }
    /// 显示/隐藏（右上角）
    @discardableResult
    func setCornerBadgeHidden(_ hidden: Bool,
                              animated: Bool = false,
                              duration: TimeInterval = 0.2) -> Self {
        guard let v = rt_badgeContainer() else { return self }
        let work = { v.alpha = hidden ? 0 : 1 }
        animated ? UIView.animate(withDuration: duration, animations: work) : work()
        return self
    }
    /// 移除（右上角）
    @discardableResult
    func removeCornerBadge() -> Self {
        rt_badgeContainer()?.removeFromSuperview()
        setRTBadgeContainer(nil)
        return self
    }
}

private final class _BadgeContainerView: UIView {
    var autoCapsule: Bool = true
    override func layoutSubviews() {
        super.layoutSubviews()
        if autoCapsule {
            byCornerRadius(bounds.height / 2)
        }
    }
}

private final class _InsetLabel: UILabel {
    /// 文本内容的内边距（默认为 .zero）
    var contentInsets: UIEdgeInsets = .zero {
        didSet {
            guard oldValue != contentInsets else { return }
            invalidateIntrinsicContentSize()
            refresh()
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    /// 实际绘制：直接在缩减后的区域画
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }
    /// 参与 Auto Layout 的固有尺寸：加上内边距
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + contentInsets.left + contentInsets.right,
                      height: s.height + contentInsets.top + contentInsets.bottom)
    }
    /// 计算文本绘制矩形：先缩进，再把结果外扩回去（系统要求）
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        /// 先将可用区域减去内边距
        let insetBounds = bounds.inset(by: contentInsets)
        /// 让父类在缩减后的区域中排版
        let textRect = super.textRect(forBounds: insetBounds, limitedToNumberOfLines: numberOfLines)
        /// 再把结果外扩回原坐标系（相当于“反向”内边距）
        let out = UIEdgeInsets(top: -contentInsets.top, left: -contentInsets.left,
                               bottom: -contentInsets.bottom, right: -contentInsets.right)
        return textRect.inset(by: out)
    }
}
// MARK: - 链式 DSL
private extension _InsetLabel {
    /// 直接设置 UIEdgeInsets
    @discardableResult
    func byContentInsets(_ insets: UIEdgeInsets) -> Self {
        self.contentInsets = insets
        return self
    }
    /// 上下左右等距
    @discardableResult
    func byContentInsets(_ all: CGFloat) -> Self {
        self.contentInsets = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
        return self
    }
    /// 垂直/水平 分量设置（例如 vertical=6, horizontal=10）
    @discardableResult
    func byContentInsets(vertical v: CGFloat, horizontal h: CGFloat) -> Self {
        self.contentInsets = UIEdgeInsets(top: v, left: h, bottom: v, right: h)
        return self
    }
    /// 分别指定四边
    @discardableResult
    func byContentInsets(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> Self {
        self.contentInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return self
    }
}
/// 仅一个 key（右上角）
private enum _RTBadgeKey { static var tr: UInt8 = 0 }
private extension UIView {

    func ensureRTBadgeContainer() -> _BadgeContainerView {
        if let v = rt_badgeContainer() as? _BadgeContainerView { return v }
        let v = _BadgeContainerView()
        setRTBadgeContainer(v)
        addSubview(v)
        return v
    }

    func rt_badgeContainer() -> UIView? {
        objc_getAssociatedObject(self, &_RTBadgeKey.tr) as? UIView
    }

    func setRTBadgeContainer(_ v: UIView?) {
        objc_setAssociatedObject(self, &_RTBadgeKey.tr, v, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func install(_ content: RTBadgeContent, into container: _BadgeContainerView, config: RTBadgeConfig) {
        container.subviews.forEach { $0.removeFromSuperview() }

        switch content {
        case .text(let s):
            let label = _InsetLabel()
                .byText(s)
                .byTextColor(config.textColor)
                .byFont(config.font)
                .byNumberOfLines(1)
                .byContentInsets(config.insets)
            container.addSubview(label)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.snp.makeConstraints { $0.edges.equalToSuperview() }

        case .attributed(let attr):
            let label = _InsetLabel()
                .byAttributedString(attr)
                .byTextColor(config.textColor)
                .byFont(config.font)
                .byNumberOfLines(1)
                .byContentInsets(config.insets)
            container.addSubview(label)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.snp.makeConstraints { $0.edges.equalToSuperview() }

        case .custom(let view):
            container.addSubview(view)
            view.snp.makeConstraints { $0.edges.equalToSuperview().inset(config.insets) }
        }
    }
    /// 右上角定位（统一 remake，避免重复约束）
    func installRTBadgeConstraints(container: UIView,
                                   offset: UIOffset,
                                   maxWidth: CGFloat) {
        // ② installRTBadgeConstraints(container:offset:maxWidth:)
        container.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(offset.vertical)
            make.right.equalToSuperview().offset(offset.horizontal)
            make.width.lessThanOrEqualTo(maxWidth)
        }
        container.setContentCompressionResistancePriority(.required, for: .horizontal)
        container.setContentHuggingPriority(.required, for: .horizontal)
    }
}
// MARK: - 回调协议：任何宿主视图（含 BaseWebView）都可感知 NavBar 显隐变化并自行调整内部布局
@MainActor
public protocol JobsNavBarHost: AnyObject {
    /// enabled: true=已安装；false=已移除
    func jobsNavBarDidToggle(enabled: Bool, navBar: JobsNavBar)
}
// MARK: - 关联对象 Key（用 UInt8 的地址唯一标识）
private enum _JobsNavBarAO {
    static var bar:  UInt8 = 0
    static var conf: UInt8 = 0
}
// MARK: - 配置体（挂在 UIView 上，而不是某个具体子类）
public extension UIView {
    struct JobsNavBarConfig {
        public var enabled: Bool = false
        public var style: JobsNavBar.Style = .init()
        public var titleProvider: JobsNavBar.TitleProvider? = nil          // nil -> 隐藏标题；不设=由宿主决定
        public var backButtonProvider: JobsNavBar.BackButtonProvider? = nil// nil -> 隐藏返回键
        public var onBack: JobsNavBar.BackHandler? = nil                   // 未设置则由宿主兜底
        public var layout: ((JobsNavBar, ConstraintMaker, UIView) -> Void)? = nil // 自定义布局
        public var backButtonLayout: ((JobsNavBar, UIButton, ConstraintMaker) -> Void)? = nil
        public init() {}
    }
}
// MARK: - 公开：取到当前视图身上的 NavBar（只读）
public extension UIView {
    var jobsNavBar: JobsNavBar? {
        objc_getAssociatedObject(self, &_JobsNavBarAO.bar) as? JobsNavBar
    }
    /// 是否存在可见的“导航栏类视图”（优先 GKNavigationBar，其次 UINavigationBar）
    /// - Parameter deep: 是否递归遍历整棵子树（默认 true）
    func jobs_hasVisibleTopBar(deep: Bool = true) -> Bool {
    #if canImport(GKNavigationBarSwift)
        return jobs_existingTopBar(deep: deep) != nil
    #else
        return false
    #endif
    }
}
// MARK: - 私有：配置读写 + 应用
@MainActor
private extension UIView {
    var _jobsNavBarConfig: JobsNavBarConfig {
        get { (objc_getAssociatedObject(self, &_JobsNavBarAO.conf) as? JobsNavBarConfig) ?? .init() }
        set { objc_setAssociatedObject(self, &_JobsNavBarAO.conf, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func _setJobsNavBar(_ bar: JobsNavBar?) {
        objc_setAssociatedObject(self, &_JobsNavBarAO.bar, bar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func _applyNavBarConfig() {
        let cfg = _jobsNavBarConfig
        if cfg.enabled {
            let bar: JobsNavBar
            if let b = jobsNavBar {
                bar = b
                bar.style = cfg.style
            } else {
                bar = JobsNavBar(style: cfg.style)
                addSubview(bar)
                _setJobsNavBar(bar)
            }
            // 提供器（返回 nil -> 隐藏）
            bar.titleProvider = cfg.titleProvider
            bar.backButtonProvider = cfg.backButtonProvider
            // ✅ 透传外层 backButtonLayout（触发 didSet -> 只重排约束，不重复 add）
            bar.backButtonLayout = cfg.backButtonLayout
            // 返回行为
            if let onBack = cfg.onBack { bar.onBack = onBack }
            // 布局 NavBar 本体（与返回键无关）
            bar.snp.remakeConstraints { make in
                if let L = cfg.layout {
                    L(bar, make, self)
                } else {
                    make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
                    make.left.right.equalToSuperview()
                }
            }
            (self as? JobsNavBarHost)?.jobsNavBarDidToggle(enabled: true, navBar: bar)
        } else {
            if let bar = jobsNavBar {
                bar.removeFromSuperview()
                _setJobsNavBar(nil)
                (self as? JobsNavBarHost)?.jobsNavBarDidToggle(enabled: false, navBar: bar)
            }
        }
    }
}

@MainActor
public extension UIView {
    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        // 只查一层足够；要递归可以展开
        return subviews.first { $0 is T } as? T
    }
}
// MARK: - UIView 链式 DSL（任何 UIView 均可使用）
@MainActor
public extension UIView {
    @discardableResult
    func byNavBarEnabled(_ on: Bool = true) -> Self {
        var c = _jobsNavBarConfig
        c.enabled = on
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }

    @discardableResult
    func byNavBarStyle(_ edit: (inout JobsNavBar.Style) -> Void) -> Self {
        var c = _jobsNavBarConfig
        edit(&c.style)
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }
    /// 自定义标题（返回 nil -> 隐藏；不设置则留给宿主绑定，例如绑定到 webView.title）
    @discardableResult
    func byNavBarTitleProvider(_ p: @escaping JobsNavBar.TitleProvider) -> Self {
        var c = _jobsNavBarConfig
        c.titleProvider = p
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }
    /// 自定义返回键（返回 nil -> 隐藏）
    @discardableResult
    func byNavBarBackButtonProvider(_ p: @escaping JobsNavBar.BackButtonProvider) -> Self {
        var c = _jobsNavBarConfig
        c.backButtonProvider = p
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }
    /// 自定义返回键@约束
    @discardableResult
    func byNavBarBackButtonLayout(_ layout: @escaping JobsNavBar.BackButtonLayout) -> Self {
        var c = _jobsNavBarConfig
        c.backButtonLayout = layout
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }
    /// 返回行为（比如“优先 webView.goBack，否则 pop”）
    @discardableResult
    func byNavBarOnBack(_ h: @escaping JobsNavBar.BackHandler) -> Self {
        var c = _jobsNavBarConfig
        c.onBack = h
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }
    /// 覆盖默认布局（默认：贴宿主 safeArea 顶，左右铺满）
    @discardableResult
    func byNavBarLayout(_ layout: @escaping (JobsNavBar, ConstraintMaker, UIView) -> Void) -> Self {
        var c = _jobsNavBarConfig
        c.layout = layout
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }
}
#endif

#if canImport(GKNavigationBarSwift) && canImport(SnapKit)
import GKNavigationBarSwift
@MainActor
public extension UIView {
    /// 返回已存在的“导航栏类视图”（不触发懒加载），找不到返回 nil。
    /// 类型统一用 UIView?，外部无需依赖 GKNavigationBar 的符号。
    func jobs_existingTopBar(deep: Bool = true) -> UIView? {
        #if canImport(GKNavigationBarSwift)
        if let nb = jobs_firstSubview(of: GKNavigationBar.self, deep: deep),
           !nb.isHidden, nb.alpha > 0.001 {
            return nb
        }
        #endif
        if let nb = jobs_firstSubview(of: UINavigationBar.self, deep: deep),
           !nb.isHidden, nb.alpha > 0.001 {
            return nb
        }
        return nil
    }
    // MARK: - 私有工具：按类型查找已存在的子视图（不会触发任何懒创建）
    private func jobs_firstSubview<T: UIView>(of type: T.Type, deep: Bool) -> T? {
        // 先一层
        if let hit = subviews.first(where: { $0 is T }) as? T { return hit }
        // 需要递归则继续
        guard deep else { return nil }
        for v in subviews {
            if let hit: T = v.jobs_firstSubview(of: type, deep: true) { return hit }
        }
        return nil
    }
}
#endif
// MARK: - 动画@旋转
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
/// 动画@点击放大
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
#if canImport(SnapKit) && canImport(Lottie)
import SnapKit
import Lottie

public extension UIView {
    // 关联存储：挂载在任意 UIView 上的唯一 LottieAnimationView（够用了；要多实例你可以自行扩展一个池）
    private struct _JobsLottieAssoc {
        static var viewKey: UInt8 = 0
    }
    /// 当前挂载在该视图上的 Lottie 动画视图
    var jobs_lottieView: LottieAnimationView? {
        get { objc_getAssociatedObject(self, &_JobsLottieAssoc.viewKey) as? LottieAnimationView }
        set { objc_setAssociatedObject(self, &_JobsLottieAssoc.viewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    // MARK: 入口：按资源名创建并挂载
    /// 在当前 UIView 上创建并挂载一个 Lottie 动画（默认贴满父视图）
    /// - Parameters:
    ///   - name: Assets / main bundle 中的动画文件名（不带扩展名）
    ///   - bundle: 动画所在 bundle（默认 .main）
    ///   - loop: 循环模式（默认 .loop）
    ///   - speed: 播放速度（默认 1.0）
    ///   - contentMode: 内容适配（默认 .scaleAspectFit）
    ///   - backgroundBehavior: 退后台行为（默认 .pauseAndRestore）
    ///   - autoPlay: 是否自动播放（默认 false）
    ///   - makeConstraints: SnapKit 约束（默认贴满父视图）
    ///   - configure: 最后补充配置（可选）
    /// - Returns: 新建并已挂载的 LottieAnimationView（链式继续 .play() 等）
    @discardableResult
    func byLottieAnimation(
        _ name: String,
        bundle: Bundle = .main,
        loop: LottieLoopMode = .loop,
        speed: CGFloat = 1.0,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        backgroundBehavior: LottieBackgroundBehavior = .pauseAndRestore,
        autoPlay: Bool = false,
        makeConstraints: ((ConstraintMaker) -> Void)? = { $0.edges.equalToSuperview() },
        configure: ((LottieAnimationView) -> Void)? = nil
    ) -> LottieAnimationView {
        // 1) 创建
        let lottieView = LottieAnimationView(name: name, bundle: bundle)
            .bySpeed(speed)
            .byLoop(loop)
            .byLottieContentMode(contentMode)
            .byBackgroundBehavior(backgroundBehavior)
        // 2) 挂载 + 约束
        if lottieView.superview !== self {
            addSubview(lottieView)
        }
        if let make = makeConstraints {
            lottieView.snp.makeConstraints(make)
        }
        // 3) 额外配置
        configure?(lottieView)
        // 4) 记录引用
        self.jobs_lottieView = lottieView
        // 5) 自动播放（可选）
        if autoPlay { lottieView.play() }

        return lottieView
    }
    // MARK: 入口（重载）：直接传 LottieAnimation
    /// 你也可以先用 `LottieAnimation.named(...)` 自行解析，再走这个重载
    @discardableResult
    func byLottieAnimation(
        _ animation: LottieAnimation,
        loop: LottieLoopMode = .loop,
        speed: CGFloat = 1.0,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        backgroundBehavior: LottieBackgroundBehavior = .pauseAndRestore,
        autoPlay: Bool = false,
        makeConstraints: ((ConstraintMaker) -> Void)? = { $0.edges.equalToSuperview() },
        configure: ((LottieAnimationView) -> Void)? = nil
    ) -> LottieAnimationView {
        let lottieView = LottieAnimationView(animation: animation)
        lottieView.loopMode = loop
        lottieView.animationSpeed = speed
        lottieView.contentMode = contentMode
        lottieView.backgroundBehavior = backgroundBehavior

        if lottieView.superview !== self {
            addSubview(lottieView)
        }
        if let make = makeConstraints {
            lottieView.snp.makeConstraints(make)
        }
        configure?(lottieView)
        self.jobs_lottieView = lottieView
        if autoPlay { lottieView.play() }
        return lottieView
    }
    // MARK: - UIView 层便捷控制（保持语义链式）
    @discardableResult
    func lottiePlay(completion: ((Bool) -> Void)? = nil) -> Self {
        jobs_lottieView?.play(completion: completion)
        return self
    }

    @discardableResult
    func lottiePause() -> Self {
        jobs_lottieView?.pause()
        return self
    }
    /// 停止并可选重置到起点
    @discardableResult
    func lottieStop(resetToBeginning: Bool = false) -> Self {
        jobs_lottieView?.stop()
        if resetToBeginning { jobs_lottieView?.currentProgress = 0 }
        return self
    }
    /// 设置进度（0~1）
    @discardableResult
    func lottieProgress(_ progress: CGFloat) -> Self {
        jobs_lottieView?.currentProgress = min(max(progress, 0), 1)
        return self
    }
    /// 替换动画资源（保留其他播放参数）
    @discardableResult
    func lottieReplace(name: String, bundle: Bundle = .main, autoPlay: Bool = false) -> Self {
        guard let v = jobs_lottieView else { return self }
        v.animation = LottieAnimation.named(name, bundle: bundle)
        if autoPlay { v.play() }
        return self
    }
    /// 卸载当前挂载的 Lottie 视图
    @discardableResult
    func lottieRemove() -> Self {
        jobs_lottieView?.removeFromSuperview()
        jobs_lottieView = nil
        return self
    }
}
// MARK: - LottieAnimationView 小型 DSL（可选：增强链式体验）
public extension LottieAnimationView {
    @discardableResult
    func byLoop(_ mode: LottieLoopMode) -> Self { loopMode = mode; return self }

    @discardableResult
    func bySpeed(_ value: CGFloat) -> Self { animationSpeed = value; return self }

    @discardableResult
    func byLottieContentMode(_ mode: UIView.ContentMode) -> Self { contentMode = mode; return self }

    @discardableResult
    func byBackgroundBehavior(_ behavior: LottieBackgroundBehavior) -> Self {
        backgroundBehavior = behavior
        return self
    }
}
#endif
/// 封装在UIView层的✅确认和🚫取消回调
public typealias JobsConfirmHandler = () -> Void
public typealias JobsCancelHandler  = () -> Void
private struct JobsConfirmKeys {
    static var confirm: UInt8 = 0
    static var cancel:  UInt8 = 0
}

public extension UIView {
    var confirmHandler: JobsConfirmHandler? {
        get {
            objc_getAssociatedObject(self, &JobsConfirmKeys.confirm) as? JobsConfirmHandler
        }
        set {
            objc_setAssociatedObject(self,
                                     &JobsConfirmKeys.confirm,
                                     newValue,
                                     .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    var cancelHandler: JobsCancelHandler? {
        get {
            objc_getAssociatedObject(self, &JobsConfirmKeys.cancel) as? JobsCancelHandler
        }
        set {
            objc_setAssociatedObject(self,
                                     &JobsConfirmKeys.cancel,
                                     newValue,
                                     .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    /// 确认回调
    @discardableResult
    func onConfirm(_ handler: @escaping JobsConfirmHandler) -> Self {
        confirmHandler = handler
        return self
    }
    /// 取消回调
    @discardableResult
    func onCancel(_ handler: @escaping JobsCancelHandler) -> Self {
        cancelHandler = handler
        return self
    }

    func jobs_fireConfirm() {
        confirmHandler?()
    }

    func jobs_fireCancel() {
        cancelHandler?()
    }
}
