//
//  UIButton.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.

//  说明（本版仅“计时器”相关做了统一改造，UI 链式等其余原样保留）：
//  -----------------------------------------------------------------------------
//  - 外部只需一个“是否传 total”的参数差异，即可决定【正计时】（不传）或【倒计时】（传）。
//  - 计时器实例统一挂在按钮上：`button.timer`（不再使用 jobsTimer）。
//  - 统一链式事件（与 onTap 同级）：
//      `onTimerTick { btn, current, total?, kind in ... }`
//      `onTimerFinish { btn, kind in ... }`
//    语义化别名（倒计时专用）：`onCountdownTick` / `onCountdownFinish`。
//  - 统一控制 API：
//      `startTimer(total: Int? = nil, interval: TimeInterval = 1.0, kind: JobsTimerKind = .gcd)`
//      `pauseTimer()` / `resumeTimer()` / `fireTimerOnce()` / `stopTimer()`
//    并保留兼容封装：`startJobsTimer(...)` 等（内部转调新 API）。
//  - 内建按钮级状态机：`timerState`（idle / running / paused / stopped），可用
//      `onTimerStateChange { btn, old, new in ... }` 订阅；
//    默认的 UI 变化已内置（想自己接管就设置 onTimerStateChange 覆盖）。
//

#if os(OSX)
import AppKit
#endif

#if os(iOS) || os(tvOS)
import UIKit
#endif

import Foundation
import ObjectiveC

#if canImport(JobsSwiftBaseTools)
import JobsSwiftBaseTools
#endif

public extension UIButton {
    @available(iOS 7.0, *)
    static func sys() -> UIButton {
        UIButton(type: .system).byBackgroundColor(.clear)
    }
    @available(iOS 13.0, *)
    static func close() -> UIButton {
        UIButton(type: .close).byBackgroundColor(.clear)
    }

    static func custom() -> UIButton {
        UIButton(type: .custom).byBackgroundColor(.clear)
    }

    static func detailDisclosure() -> UIButton {
        UIButton(type: .detailDisclosure).byBackgroundColor(.clear)
    }

    static func infoLight() -> UIButton {
        UIButton(type: .infoLight).byBackgroundColor(.clear)
    }

    static func infoDark() -> UIButton {
        UIButton(type: .infoDark).byBackgroundColor(.clear)
    }

    static func contactAdd() -> UIButton {
        UIButton(type: .contactAdd).byBackgroundColor(.clear)
    }
}

private var _jobsBGURLKey:   UInt8 = 0   // URL?
private var _jobsBGStateKey: UInt8 = 0   // UIControl.State.RawValue
private var _jobsIsCloneKey: UInt8 = 0   // Bool
public extension UIButton {
    /// 最近一次设置“背景图”的 URL（供克隆或复用）
    var jobs_bgURL: URL? {
        get { objc_getAssociatedObject(self, &_jobsBGURLKey) as? URL }
        set { objc_setAssociatedObject(self, &_jobsBGURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    /// 最近一次设置背景图时使用的 state
    var jobs_bgState: UIControl.State {
        get { UIControl.State(rawValue: (objc_getAssociatedObject(self, &_jobsBGStateKey) as? UInt) ?? UIControl.State.normal.rawValue) }
        set { objc_setAssociatedObject(self, &_jobsBGStateKey, newValue.rawValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    /// 是否“克隆按钮”：克隆时禁用过渡动画、优先现成位图/缓存
    var jobs_isClone: Bool {
        get { (objc_getAssociatedObject(self, &_jobsIsCloneKey) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &_jobsIsCloneKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
// MARK: - 基础链式
public extension UIButton {
    @discardableResult
    func byTitle(_ title: String?, for state: UIControl.State = .normal) -> Self {
        self.setTitle(title, for: state)
        if #available(iOS 15.0, *), var cfg = self.configuration {
            if state == .normal { cfg.title = title }
            self.configuration = cfg
            byUpdateConfig()
        };return self
    }

    @discardableResult
    func byAttributedTitle(_ text: NSAttributedString?, for state: UIControl.State = .normal) -> Self {
        self.setAttributedTitle(text, for: state)
        return self
    }

    @discardableResult
    func byTitleFont(_ font: UIFont) -> Self {
        self.titleLabel?.font = font
        if #available(iOS 15.0, *), self.configuration != nil {
            var cfg = self.configuration ?? .filled()
            cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var attrs = incoming
                attrs.font = font
                return attrs
            }
            self.configuration = cfg
            byUpdateConfig()
        };return self
    }

    @discardableResult
    func byTitleColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        self.setTitleColor(color, for: state)
        if #available(iOS 15.0, *), var cfg = self.configuration {
            if state == .normal {
                cfg.baseForegroundColor = color
                self.configuration = cfg
                byUpdateConfig()
            }
        };return self
    }

    @discardableResult
    func byTitleShadowColor(_ color: UIColor?, for state: UIControl.State = .normal) -> Self {
        self.setTitleShadowColor(color, for: state)
        return self
    }

    @discardableResult
    func byImage(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
        self.setImage(image, for: state)
        return self
    }

    @available(iOS 13.0, *)
    @discardableResult
    func byPreferredSymbolConfiguration(_ configuration: UIImage.SymbolConfiguration?,
                                       forImageIn state: UIControl.State = .normal) -> Self {
        self.setPreferredSymbolConfiguration(configuration, forImageIn: state)
        return self
    }

    @discardableResult
    func byBackgroundImage(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
        #if DEBUG
        if image == nil { print("❗️byBackgroundImage: image is nil for state=\(state)") }
        #endif
        if #available(iOS 15.0, *), state == .normal {
            var cfg = self.configuration ?? .filled()
            if cfg.title == nil, let t = self.title(for: .normal), !t.isEmpty { cfg.title = t }
            if cfg.baseForegroundColor == nil, let tc = self.titleColor(for: .normal) { cfg.baseForegroundColor = tc }
            var bg = cfg.background
            bg.image = image
            bg.imageContentMode = .scaleAspectFill
            cfg.background = bg
            self.configuration = cfg
            byUpdateConfig()
        } else {
            self.setBackgroundImage(image, for: state)
        };return self
    }

    @discardableResult
    func byBackgroundImageContentMode(_ mode: UIView.ContentMode) -> Self {
        if #available(iOS 15.0, *), var cfg = self.configuration {
            var bg = cfg.background
            bg.imageContentMode = mode         // .scaleAspectFill / .scaleAspectFit
            cfg.background = bg
            self.configuration = cfg
        };return self
    }

    @discardableResult
    func byTintColor(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func byUpdateConfig() -> Self {
        self.setNeedsUpdateConfiguration()
        self.updateConfiguration()
        self.automaticallyUpdatesConfiguration = true
        return self
    }
}
// MARK: - 进阶：按 state 的链式代理
public extension UIButton {
    final class StateProxy {
        fileprivate let button: UIButton
        let state: UIControl.State

        init(button: UIButton, state: UIControl.State) {
            self.button = button
            self.state = state
        }

        @discardableResult
        func title(_ text: String?) -> UIButton { button.setTitle(text, for: state); return button }
        @discardableResult
        func attributedTitle(_ text: NSAttributedString?) -> UIButton { button.setAttributedTitle(text, for: state); return button }
        @discardableResult
        func titleColor(_ color: UIColor?) -> UIButton { button.setTitleColor(color, for: state); return button }
        @discardableResult
        func titleShadowColor(_ color: UIColor?) -> UIButton { button.setTitleShadowColor(color, for: state); return button }
        @discardableResult
        func image(_ image: UIImage?) -> UIButton { button.setImage(image, for: state); return button }

        @available(iOS 13.0, *)
        @discardableResult
        func preferredSymbolConfiguration(_ configuration: UIImage.SymbolConfiguration?) -> UIButton {
            button.setPreferredSymbolConfiguration(configuration, forImageIn: state); return button
        }

        @discardableResult
        func backgroundColor(_ color: UIColor) -> UIButton {
            if #available(iOS 15.0, *), state == .normal {
                var cfg = button.configuration ?? .filled()
                cfg.baseBackgroundColor = color
                var bg = cfg.background
                bg.backgroundColor = color
                cfg.background = bg
                button.configuration = cfg
                button.byUpdateConfig()
            } else {
                button.setBackgroundColor(color, forState: state)
            }
            return button
        }

        @discardableResult
        func backgroundImage(_ image: UIImage?) -> UIButton { button.setBackgroundImage(image, for: state); return button }

        @discardableResult
        func subTitle(_ text: String?) -> UIButton { button.bySubTitle(text, for: state) }
        @discardableResult
        func subTitleFont(_ font: UIFont) -> UIButton { button.bySubTitleFont(font, for: state) }
        @discardableResult
        func subTitleColor(_ color: UIColor) -> UIButton { button.bySubTitleColor(color, for: state) }
    }

    func `for`(_ state: UIControl.State) -> StateProxy { StateProxy(button: self, state: state) }
}
// MARK: - 布局 / 外观
public extension UIButton {
    @discardableResult
    func byBackgroundColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *), state == .normal {
            var cfg = self.configuration ?? .filled()
            cfg.baseBackgroundColor = color
            var bg = cfg.background
            bg.backgroundColor = color
            cfg.background = bg
            if cfg.title == nil, let t = self.title(for: .normal), !t.isEmpty { cfg.title = t }
            if cfg.baseForegroundColor == nil, let tc = self.titleColor(for: .normal) { cfg.baseForegroundColor = tc }
            self.configuration = cfg
            byUpdateConfig()
        } else {
            self.setBgCor(color, forState: state)
        };return self
    }

    @discardableResult
    func byNormalBgColor(_ color: UIColor) -> Self { byBackgroundColor(color, for: .normal) }

    @discardableResult
    func byNumberOfLines(_ lines: Int) -> Self { titleLabel?.numberOfLines = lines; return self }

    @discardableResult
    func byLineBreakMode(_ mode: NSLineBreakMode) -> Self { titleLabel?.lineBreakMode = mode; return self }

    @discardableResult
    func byTitleAlignment(_ alignment: NSTextAlignment) -> Self { titleLabel?.textAlignment = alignment; return self }

    @discardableResult
    func byContentInsets(_ insets: NSDirectionalEdgeInsets) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .filled()
            cfg.contentInsets = insets
            configuration = cfg
            byUpdateConfig()
        } else {
            contentEdgeInsets = UIEdgeInsets(top: insets.top, left: insets.leading, bottom: insets.bottom, right: insets.trailing)
        };return self
    }

    @discardableResult
    func byContentEdgeInsets(_ insets: UIEdgeInsets) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .filled()
            cfg.contentInsets = NSDirectionalEdgeInsets(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
            configuration = cfg
            byUpdateConfig()
        } else {
            self.contentEdgeInsets = insets
        };return self
    }

    @discardableResult
    func byImageEdgeInsets(_ insets: UIEdgeInsets) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .filled()
            cfg.imagePadding = (insets.left + insets.right) / 2
            configuration = cfg
            byUpdateConfig()
        } else {
            self.imageEdgeInsets = insets
        };return self
    }

    @discardableResult
    func byTitleEdgeInsets(_ insets: UIEdgeInsets) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .filled()
            cfg.contentInsets = NSDirectionalEdgeInsets(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
            configuration = cfg
            byUpdateConfig()
        } else {
            self.titleEdgeInsets = insets
        };return self
    }

    @discardableResult
    func byBorder(color: UIColor, width: CGFloat) -> Self {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        return self
    }
    // MARK: - 阴影
    @discardableResult
    func byMasksToBounds(radius: Bool) -> Self {
        layer.masksToBounds = radius
        return self
    }
    
    @discardableResult
    func byShadow(color: UIColor = .black,
                  opacity: Float = 0.15,
                  radius: CGFloat = 6,
                  offset: CGSize = .init(width: 0, height: 2)) -> Self {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.masksToBounds = false
        return self
    }
    /// 图文位置关系
    @discardableResult
    func byImagePlacement(_ placement: NSDirectionalRectEdge, padding: CGFloat = 8) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .filled()
            cfg.imagePlacement = placement
            cfg.imagePadding = padding
            configuration = cfg
            byUpdateConfig()
        } else {
            switch placement {
            case .leading:  semanticContentAttribute = .forceLeftToRight
            case .trailing: semanticContentAttribute = .forceRightToLeft
            case .top, .bottom:
                let inset = padding / 2
                contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            default: break
            }
        };return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func byConfiguration(_ build: (UIButton.Configuration) -> UIButton.Configuration) -> Self {
        let current = self.configuration ?? .filled()
        self.configuration = build(current)
        byUpdateConfig()
        return self
    }
}

private extension UIControl.State { var raw: UInt { rawValue } }
// MARK: - Subtitle（无富文本）
private struct _JobsSubPackNoAttr {
    var text: String = ""
    var font: UIFont?
    var color: UIColor?
}
private var _jobsSubDictKey_noAttr: UInt8 = 0
private var _jobsSubtitleHandlerInstalledKey: UInt8 = 0
private var _jobsCfgBgImageKey: UInt8 = 0
private extension UIButton {
    var jobs_cfgBgImage: UIImage? {
        get { objc_getAssociatedObject(self, &_jobsCfgBgImageKey) as? UIImage }
        set { objc_setAssociatedObject(self, &_jobsCfgBgImageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    var _subDict_noAttr: [UInt: _JobsSubPackNoAttr] {
        get { (objc_getAssociatedObject(self, &_jobsSubDictKey_noAttr) as? [UInt: _JobsSubPackNoAttr]) ?? [:] }
        set { objc_setAssociatedObject(self, &_jobsSubDictKey_noAttr, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func _subPack_noAttr(for state: UIControl.State, create: Bool = true) -> _JobsSubPackNoAttr {
        var d = _subDict_noAttr
        if let p = d[state.raw] { return p }
        if create {
            let p = _JobsSubPackNoAttr()
            d[state.raw] = p
            _subDict_noAttr = d
            return p
        };return _JobsSubPackNoAttr()
    }

    func _setSubPack_noAttr(_ p: _JobsSubPackNoAttr, for state: UIControl.State) {
        var d = _subDict_noAttr; d[state.raw] = p; _subDict_noAttr = d
        _ensureSubtitleHandler_noAttrInstalled()
        if #available(iOS 15.0, *) { setNeedsUpdateConfiguration() }
    }

    func _ensureSubtitleHandler_noAttrInstalled() {
        // 已安装就不重复装
        if (objc_getAssociatedObject(self, &_jobsSubtitleHandlerInstalledKey) as? Bool) == true { return }
        objc_setAssociatedObject(self, &_jobsSubtitleHandlerInstalledKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        let existing = self.configurationUpdateHandler
        self.automaticallyUpdatesConfiguration = true

        self.configurationUpdateHandler = { [weak self] btn in
            // 先把外部原有的 handler 执行（不抢控制权）
            existing?(btn)
            guard let self = self else { return }

            // 当前状态
            let st = btn.state

            // 拿到（或创建）当前配置
            var cfg = btn.configuration ?? .plain()
            cfg.titleAlignment = .center

            // ---------- 主标题：防丢 ----------
            if cfg.title == nil,
               let t = btn.title(for: .normal),
               !t.isEmpty {
                cfg.title = t
            }

            // ---------- 副标题：从我们保存的包读取并应用 ----------
            // _subDict_noAttr 是你已有的 AO 字典：[UInt : _JobsSubPackNoAttr]
            let pack = self._subDict_noAttr[st.rawValue] ?? self._subDict_noAttr[UIControl.State.normal.rawValue]
            let subText = pack?.text ?? ""
            cfg.subtitle = subText.isEmpty ? nil : subText

            let f = pack?.font
            let c = pack?.color
            cfg.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var a = incoming
                if let f { a.font = f }
                if let c { a.foregroundColor = c }
                return a
            }

            // ---------- 背景图：优先“粘住”的，再兜底 legacy ----------
            // jobs_cfgBgImage 是你在 jobsResetBtnBgImage 中同步/粘住的最终图
            var bg = cfg.background
            if let keep = self.jobs_cfgBgImage {
                if bg.image !== keep {
                    bg.image = keep
                    if bg.imageContentMode == .scaleToFill { bg.imageContentMode = .scaleAspectFill }
                    bg.backgroundColor = .clear
                }
            } else if bg.image == nil {
                // 没有“粘住”的图，再尝试用 legacy 按 state 的背景图兜底，避免空
                if let legacy = self.backgroundImage(for: st) ?? self.backgroundImage(for: .normal) {
                    bg.image = legacy
                    if bg.imageContentMode == .scaleToFill { bg.imageContentMode = .scaleAspectFill }
                    bg.backgroundColor = .clear
                }
            }
            cfg.background = bg

            // ---------- 提交 ----------
            btn.configuration = cfg
            // 不要在这里再 setNeedsUpdateConfiguration()，避免循环重建
        }
    }

    func _legacy_applySubtitle_noAttr(text: String?, for state: UIControl.State) {
        let titleText = self.title(for: state)
            ?? self.attributedTitle(for: state)?.string
            ?? self.title(for: .normal)
            ?? self.attributedTitle(for: .normal)?.string
            ?? ""
        let full = text.map { titleText.isEmpty ? $0 : "\(titleText)\n\($0)" } ?? titleText
        setTitle(full, for: state)
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
    }
}

public extension UIButton {
    @discardableResult
    func bySubTitle(_ text: String?, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *) {
            var p = _subPack_noAttr(for: state); p.text = text ?? ""; _setSubPack_noAttr(p, for: state)
            // ⬇️ 立刻写入配置，保证首次就能看到
            _applySubtitleToConfigurationNow(targetState: state)
        } else {
            _legacy_applySubtitle_noAttr(text: text, for: state)
        };return self
    }
    @discardableResult
    func bySubTitleFont(_ font: UIFont, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *) {
            var p = _subPack_noAttr(for: state); p.font = font; _setSubPack_noAttr(p, for: state)
            _applySubtitleToConfigurationNow(targetState: state)   // ⬅️
        };return self
    }
    @discardableResult
    func bySubTitleColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *) {
            var p = _subPack_noAttr(for: state); p.color = color; _setSubPack_noAttr(p, for: state)
            _applySubtitleToConfigurationNow(targetState: state)   // ⬅️
        };return self
    }
}
// MARK: - 交互 / 菜单 / 角色 / Pointer / Config 生命周期
public extension UIButton {
    @available(iOS 14.0, *)
    @discardableResult
    func byMenu(_ menu: UIMenu?) -> Self { self.menu = menu; return self }

    @available(iOS 13.4, *)
    @discardableResult
    func byPointerInteractionEnabled(_ on: Bool) -> Self { self.isPointerInteractionEnabled = on; return self }

    @available(iOS 14.0, *)
    @discardableResult
    func byRole(_ role: UIButton.Role) -> Self { self.role = role; return self }

    @available(iOS 16.0, *)
    @discardableResult
    func byPreferredMenuElementOrder(_ order: UIContextMenuConfiguration.ElementOrder) -> Self {
        self.preferredMenuElementOrder = order; return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func byChangesSelectionAsPrimaryAction(_ on: Bool) -> Self { self.changesSelectionAsPrimaryAction = on; return self }

    @available(iOS 15.0, *)
    @discardableResult
    func byAutomaticallyUpdatesConfiguration(_ on: Bool) -> Self { self.automaticallyUpdatesConfiguration = on; return self }

    @available(iOS 15.0, *)
    @discardableResult
    func byConfigurationUpdateHandler(_ handler: @escaping UIButton.ConfigurationUpdateHandler) -> Self {
        self.configurationUpdateHandler = handler; return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func bySetNeedsUpdateConfiguration() -> Self { self.setNeedsUpdateConfiguration(); return self }
}
// MARK: - 便捷构造 & 背景色兜底
public extension UIButton {
    convenience init(x: CGFloat,
                            y: CGFloat,
                            w: CGFloat,
                            h: CGFloat,
                            target: AnyObject,
                            action: Selector) {
        self.init(frame: CGRect(x: x, y: y, width: w, height: h))
        addTarget(target, action: action, for: .touchUpInside)
    }

    func setBgCor(_ color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }

    fileprivate func setBackgroundColor(_ color: UIColor, forState state: UIControl.State) {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(img, for: state)
    }
}
// MARK: - 旋转动画
public extension UIButton {
    static let rotationKey = "jobs.rotation"
    enum RotationScope { case imageView, wholeButton, layer(CALayer) }

    private func targetLayer(for scope: RotationScope) -> CALayer? {
        switch scope {
        case .imageView: return self.imageView?.layer ?? self.layer
        case .wholeButton: return self.layer
        case .layer(let l): return l
        }
    }

    func isRotating(scope: RotationScope = .imageView,
                           key: String = UIButton.rotationKey) -> Bool {
        guard let tl = targetLayer(for: scope) else { return false }
        return tl.animation(forKey: key) != nil
    }

    @discardableResult
    func setRotating(_ on: Bool,
                            scope: RotationScope = .imageView,
                            duration: CFTimeInterval = 1.0,
                            repeatCount: Float = .infinity,
                            clockwise: Bool = true,
                            key: String = UIButton.rotationKey,
                            resetTransformOnStop: Bool = true) -> Self {
        guard let tl = targetLayer(for: scope) else { return self }
        if on {
            guard tl.animation(forKey: key) == nil else { return self }
            let anim = CABasicAnimation(keyPath: "transform.rotation")
            let fullTurn = CGFloat.pi * 2 * (clockwise ? 1 : -1)
            anim.fromValue = 0
            anim.toValue = fullTurn
            anim.duration = max(0.001, duration)
            anim.repeatCount = repeatCount
            anim.isCumulative = true
            anim.isRemovedOnCompletion = false
            tl.add(anim, forKey: key)
        } else {
            tl.removeAnimation(forKey: key)
            if resetTransformOnStop {
                switch scope {
                case .imageView: self.imageView?.transform = .identity
                case .wholeButton: self.transform = .identity
                case .layer: break
                }
            }
        };return self
    }

    @discardableResult
    func startRotating(duration: CFTimeInterval = 1.0,
                              scope: RotationScope = .imageView,
                              clockwise: Bool = true,
                              key: String = UIButton.rotationKey) -> Self {
        setRotating(true, scope: scope, duration: duration,
                    repeatCount: .infinity, clockwise: clockwise, key: key)
    }

    @discardableResult
    func stopRotating(scope: RotationScope = .imageView,
                             key: String = UIButton.rotationKey,
                             resetTransformOnStop: Bool = true) -> Self {
        setRotating(false, scope: scope, duration: 0,
                    repeatCount: 0, clockwise: true,
                    key: key, resetTransformOnStop: resetTransformOnStop)
    }
}
// MARK: - 防止快速连点
public extension UIButton {
    func disableAfterClick(interval: TimeInterval = 1.0) {
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.isUserInteractionEnabled = true
        }
    }
}
// ======================================================
// MARK: - 闭包回调（低版本兜底）（保留）
// ======================================================
private var actionKey: Void?
public extension UIButton {
    @discardableResult
    private func _bindTapClosure(_ action: @escaping (UIButton) -> Void,
                                 for events: UIControl.Event = .touchUpInside) -> Self {
        objc_setAssociatedObject(self, &actionKey, action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        removeTarget(self, action: #selector(_jobsHandleAction(_:)), for: events)
        addTarget(self, action: #selector(_jobsHandleAction(_:)), for: events)
        return self
    }
    @discardableResult
    func jobs_addTapClosure(_ action: @escaping (UIButton) -> Void,
                            for events: UIControl.Event = .touchUpInside) -> Self {
        _bindTapClosure(action, for: events)
    }
    @discardableResult
    func addAction(_ action: @escaping (UIButton) -> Void,
                   for events: UIControl.Event = .touchUpInside) -> Self {
        _bindTapClosure(action, for: events)
    }

    @objc private func _jobsHandleAction(_ sender: UIButton) {
        if let action = objc_getAssociatedObject(self, &actionKey) as? (UIButton) -> Void {
            action(sender)
        }
    }
}
// MARK: - 点按事件统一入口
var kJobsUIButtonLongPressSleeveKey: UInt8 = 0
public extension UIButton {
    @discardableResult
    func onTap(_ handler: @escaping (UIButton) -> Void) -> Self {
        if #available(iOS 14.0, *) {
            (self as UIControl).addAction(UIAction { [weak self] _ in
                guard let s = self else { return }
                handler(s)
            }, for: .touchUpInside)
        } else {
            _ = self.jobs_addTapClosure(handler)
        };return self
    }

    @discardableResult
     func onLongPress(minimumPressDuration: TimeInterval = 0.5,
                      _ handler: @escaping (UIButton, UILongPressGestureRecognizer) -> Void) -> Self {
         let gr = UILongPressGestureRecognizer(target: nil, action: nil)
         class _GRSleeve<T: UIGestureRecognizer> {
             let closure: (T) -> Void
             init(_ c: @escaping (T) -> Void) { closure = c }
             @objc func invoke(_ g: UIGestureRecognizer) {
                 if let gg = g as? T { closure(gg) }
             }
         }
         gr.minimumPressDuration = minimumPressDuration
         // ✅ 关键：优先用 g.view 作为按钮，这样 clone 的 button 也能拿到自己
         let sleeve = _GRSleeve<UILongPressGestureRecognizer> { [weak self] g in
             // g.view 是当前这个手势挂在哪个 view 上（模板按钮 or clone）
             guard let btn = (g.view as? UIButton) ?? self else { return }
             handler(btn, g)
         }
         gr.addTarget(
             sleeve,
             action: #selector(_GRSleeve<UILongPressGestureRecognizer>.invoke(_:))
         )
         // ✅ 不再用字符串当 key，用全局指针，clone 那边才能取得到
         objc_setAssociatedObject(
             gr,
             &kJobsUIButtonLongPressSleeveKey,
             sleeve,
             .OBJC_ASSOCIATION_RETAIN_NONATOMIC
         )
         addGestureRecognizer(gr)
         isUserInteractionEnabled = true
         return self
     }
}
// MARK: - 把按钮切到 configuration 模式
public extension UIButton {
    @available(iOS 15.0, *)
    @discardableResult
    func byAdoptConfigurationIfAvailable() -> Self {
        var cfg = self.configuration ?? .plain()
        // 同步主标题 & 颜色
        if cfg.title == nil, let t = self.title(for: .normal), !t.isEmpty { cfg.title = t }
        if cfg.baseForegroundColor == nil, let tc = self.titleColor(for: .normal) { cfg.baseForegroundColor = tc }
        // ✅ 同步“前景图”（legacy → configuration）
        if cfg.image == nil, let fg = self.image(for: .normal) {
            cfg.image = fg
        }
        // ✅ 同步“背景图”（legacy → configuration）
        var bg = cfg.background
        if bg.image == nil, let bgi = self.backgroundImage(for: .normal) {
            bg.image = bgi
            if bg.imageContentMode == .scaleToFill { bg.imageContentMode = .scaleAspectFill }
            cfg.background = bg
        }
        // 同步副标题（保持你原来的逻辑）
        if let dict = objc_getAssociatedObject(self, &_jobsSubDictKey_noAttr) as? [UInt: _JobsSubPackNoAttr],
           let pack = dict[UIControl.State.normal.rawValue], !pack.text.isEmpty {
            cfg.subtitle = pack.text
            cfg.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var a = incoming
                if let f = pack.font { a.font = f }
                if let c = pack.color { a.foregroundColor = c }
                return a
            }
        }
        self.configuration = cfg
        self.automaticallyUpdatesConfiguration = true
        self.setNeedsUpdateConfiguration()
        return self
    }
}
// MARK: - Configuration 快速编辑
@available(iOS 15.0, *)
public extension UIButton {
    @discardableResult
    func cfg(_ edit: (inout UIButton.Configuration) -> Void) -> Self {
        var c = self.configuration ?? .filled()
        edit(&c)
        self.configuration = c
        byUpdateConfig()
        return self
    }

    @discardableResult
    func cfgTitle(_ title: String?) -> Self { cfg { c in c.attributedTitle = nil; c.title = title } }

    @discardableResult
    func cfgTitleColor(_ color: UIColor) -> Self { cfg { $0.baseForegroundColor = color } }

    @discardableResult
    func cfgBackground(_ color: UIColor) -> Self { cfg { $0.baseBackgroundColor = color } }

    @discardableResult
    func cfgCorner(_ style: UIButton.Configuration.CornerStyle) -> Self { cfg { $0.cornerStyle = style } }

    @discardableResult
    func cfgInsets(_ insets: NSDirectionalEdgeInsets) -> Self { cfg { $0.contentInsets = insets } }

    @discardableResult
    func cfgFont(_ font: UIFont) -> Self {
        cfg { c in
            c.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var attrs = incoming
                attrs.font = font
                return attrs
            }
        }
    }
}
// MARK: - 关联属性：当前倒计时秒数
private var _jobsSecKey: Void?
public extension UIButton {
    var jobs_sec: Int {
        get { (objc_getAssociatedObject(self, &_jobsSecKey) as? Int) ?? 0 }
        set { objc_setAssociatedObject(self, &_jobsSecKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
// MARK: - UIButton@富文本
public extension UIButton {
    @discardableResult
    func byRichTitle(_ rich: NSAttributedString?, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = self.configuration ?? .plain()
            cfg.attributedTitle = rich.map { AttributedString($0) }
            self.configuration = cfg
            byUpdateConfig()
        } else {
            _setLegacyRichTitle(rich, for: state); _applyLegacyComposite(for: state)
        };return self
    }

    @discardableResult
    func byRichSubTitle(_ rich: NSAttributedString?, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = self.configuration ?? .plain()
            cfg.attributedSubtitle = rich.map { AttributedString($0) }
            self.configuration = cfg
            byUpdateConfig()
        } else {
            _setLegacyRichSubTitle(rich, for: state); _applyLegacyComposite(for: state)
        };return self
    }
}
private var _richTitleKey: UInt8 = 0
private var _richSubKey:   UInt8 = 0
private extension UIButton {
    typealias StateRaw = UInt

    var _legacyRichTitleMap: [StateRaw: NSAttributedString] {
        get { objc_getAssociatedObject(self, &_richTitleKey) as? [StateRaw: NSAttributedString] ?? [:] }
        set { objc_setAssociatedObject(self, &_richTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    var _legacyRichSubMap: [StateRaw: NSAttributedString] {
        get { objc_getAssociatedObject(self, &_richSubKey) as? [StateRaw: NSAttributedString] ?? [:] }
        set { objc_setAssociatedObject(self, &_richSubKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func _setLegacyRichTitle(_ rich: NSAttributedString?, for state: UIControl.State) {
        var m = _legacyRichTitleMap
        let k = state.rawValue
        if let r = rich { m[k] = r } else { m.removeValue(forKey: k) }
        _legacyRichTitleMap = m
    }
    func _setLegacyRichSubTitle(_ rich: NSAttributedString?, for state: UIControl.State) {
        var m = _legacyRichSubMap
        let k = state.rawValue
        if let r = rich { m[k] = r } else { m.removeValue(forKey: k) }
        _legacyRichSubMap = m
    }

    func _applyLegacyComposite(for state: UIControl.State) {
        let k = state.rawValue
        let title = _legacyRichTitleMap[k]
        let sub   = _legacyRichSubMap[k]

        switch (title, sub) {
        case (nil, nil):
            setAttributedTitle(nil, for: state)
        case let (t?, nil):
            setAttributedTitle(t, for: state)
        case let (nil, s?):
            setAttributedTitle(s, for: state)
        case let (t?, s?):
            titleLabel?.byNumberOfLines(0).byTextAlignment(.center)
            byAttributedTitle(NSMutableAttributedString()
                .add(t)
                .add("\n".rich)
                .add(s), for: state)
        }
    }
}
// MARK: 统一计时器
private enum _TimerMode {
    case countUp(elapsed: Int)
    case countdown(remain: Int, total: Int)
}
private extension _TimerMode {
    var isCountdown: Bool {
        if case .countdown = self { return true }
        return false
    }
}
private var _timerTickAnyKey: UInt8   = 0
private var _timerFinishAnyKey: UInt8 = 0
private var _legacyCountdownTickKey:   UInt8 = 0
private var _legacyCountdownFinishKey: UInt8 = 0
private var _timerCoreKey:  UInt8 = 0
private var _timerKindKey:  UInt8 = 0
private var _timerModeKey:  UInt8 = 0
public enum TimerState { case idle, running, paused, stopped }
private var _timerStateKey: UInt8 = 0
private var _timerStateDidChangeKey: UInt8 = 0

public extension UIButton {
    var timer: JobsTimerProtocol? {
        get { objc_getAssociatedObject(self, &_timerCoreKey) as? JobsTimerProtocol }
        set { objc_setAssociatedObject(self, &_timerCoreKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    var timerState: TimerState {
        get { (objc_getAssociatedObject(self, &_timerStateKey) as? TimerState) ?? .idle }
        set {
            let old = timerState
            objc_setAssociatedObject(self, &_timerStateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let hook = objc_getAssociatedObject(self, &_timerStateDidChangeKey) as? (UIButton, TimerState, TimerState) -> Void {
                hook(self, old, newValue)
            } else {
                applyDefaultTimerUI(for: newValue)
            }
            if #available(iOS 15.0, *) { setNeedsUpdateConfiguration() }
        }
    }

    typealias TimerStateChangeHandler = (_ button: UIButton,
                                         _ oldState: TimerState,
                                         _ newState: TimerState) -> Void

    @discardableResult
    func onTimerStateChange(_ handler: @escaping TimerStateChangeHandler) -> Self {
        objc_setAssociatedObject(self, &_timerStateDidChangeKey, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    private func applyDefaultTimerUI(for state: TimerState) {
        switch state {
        case .idle, .stopped:
            isEnabled = true; alpha = 1.0
        case .running:
            isEnabled = true; alpha = 1.0
        case .paused:
            isEnabled = true; alpha = 0.85
        }
    }

    @discardableResult
    func onTimerTick(_ handler: @escaping (_ button: UIButton,
                                           _ current: Int,
                                           _ total: Int?,
                                           _ kind: JobsTimerKind) -> Void) -> Self {
        objc_setAssociatedObject(self, &_timerTickAnyKey, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    @discardableResult
    func onTimerFinish(_ handler: @escaping (_ button: UIButton,
                                             _ kind: JobsTimerKind) -> Void) -> Self {
        objc_setAssociatedObject(self, &_timerFinishAnyKey, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    @discardableResult
    func onCountdownTick(_ handler: @escaping (_ button: UIButton,
                                               _ remain: Int, _ total: Int,
                                               _ kind: JobsTimerKind) -> Void) -> Self {
        return onTimerTick { btn, current, totalOpt, kind in
            if let total = totalOpt { handler(btn, current, total, kind) }
        }
    }

    @discardableResult
    func onCountdownFinish(_ handler: @escaping (_ button: UIButton,
                                                 _ kind: JobsTimerKind) -> Void) -> Self {
        return onTimerFinish(handler)
    }

    @discardableResult
    func startTimer(total: Int? = nil,
                    interval: TimeInterval = 1.0,
                    kind: JobsTimerKind = .gcd) -> Self {
        stopTimer()
        if let total {
            objc_setAssociatedObject(self, &_timerModeKey, _TimerMode.countdown(remain: total, total: total), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            isEnabled = false
            setTitle("\(total)s", for: .normal)
        } else {
            objc_setAssociatedObject(self, &_timerModeKey, _TimerMode.countUp(elapsed: 0), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setTitle("0", for: .normal)
        }
        objc_setAssociatedObject(self, &_timerKindKey, kind, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        let cfg = JobsTimerConfig(interval: interval, repeats: true, tolerance: 0.01, queue: .main)
        let core = JobsTimerFactory.make(kind: kind, config: cfg) { [weak self] in
            guard let self else { return }
            guard var mode = objc_getAssociatedObject(self, &_timerModeKey) as? _TimerMode else { return }
            let k = (objc_getAssociatedObject(self, &_timerKindKey) as? JobsTimerKind) ?? kind

            switch mode {
            case .countUp(let elapsed0):
                let elapsed = elapsed0 + 1
                mode = .countUp(elapsed: elapsed)
                objc_setAssociatedObject(self, &_timerModeKey, mode, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                self.setTitle("\(elapsed)", for: .normal)
                if let tick = objc_getAssociatedObject(self, &_timerTickAnyKey)
                    as? (UIButton, Int, Int?, JobsTimerKind) -> Void {
                    tick(self, elapsed, nil, k)
                }

            case .countdown(let remain0, let total):
                let remain = remain0 - 1
                if remain > 0 {
                    mode = .countdown(remain: remain, total: total)
                    objc_setAssociatedObject(self, &_timerModeKey, mode, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                    self.setTitle("\(remain)s", for: .normal)
                    if let tick = objc_getAssociatedObject(self, &_timerTickAnyKey)
                        as? (UIButton, Int, Int?, JobsTimerKind) -> Void {
                        tick(self, remain, total, k)
                    }
                    if let legacy = objc_getAssociatedObject(self, &_legacyCountdownTickKey) as? (Int, Int) -> Void {
                        legacy(remain, total)
                    }
                } else {
                    if let fin = objc_getAssociatedObject(self, &_timerFinishAnyKey)
                        as? (UIButton, JobsTimerKind) -> Void {
                        fin(self, k)
                    }
                    if let legacyFin = objc_getAssociatedObject(self, &_legacyCountdownFinishKey) as? () -> Void {
                        legacyFin()
                    }
                    self.stopTimer()
                    self.isEnabled = true
                    self.setTitle("重新获取", for: .normal)
                }
            }
        }
        self.timer = core
        self.timerState = .running
        core.start()
        return self
    }

    @discardableResult
    func pauseTimer() -> Self {
        (self.timer)?.pause()
        self.timerState = .paused
        return self
    }

    @discardableResult
    func resumeTimer() -> Self {
        (self.timer)?.resume()
        self.timerState = .running
        return self
    }

    @discardableResult
    func fireTimerOnce() -> Self {
        let mode = objc_getAssociatedObject(self, &_timerModeKey) as? _TimerMode
        (self.timer)?.fireOnce()
        self.timerState = .stopped
        if mode?.isCountdown == true {
            self.isEnabled = true
            self.setTitle("重新获取".tr, for: .normal)
        };return self
    }

    @discardableResult
    func stopTimer() -> Self {
        let mode = objc_getAssociatedObject(self, &_timerModeKey) as? _TimerMode
        if let c = self.timer { c.stop() }
        self.timer = nil
        objc_setAssociatedObject(self, &_timerModeKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.timerState = .stopped
        if mode?.isCountdown == true {
            self.isEnabled = true
            self.setTitle("重新获取".tr, for: .normal)
        };return self
    }
}

public extension UIButton {
    @discardableResult
    func startJobsTimer(total: Int? = nil,
                        interval: TimeInterval = 1.0,
                        kind: JobsTimerKind = .gcd) -> Self {
        startTimer(total: total, interval: interval, kind: kind)
    }

    @discardableResult
    func pauseJobsTimer() -> Self { pauseTimer() }

    @discardableResult
    func resumeJobsTimer() -> Self { resumeTimer() }

    @discardableResult
    func fireJobsTimerOnce() -> Self { fireTimerOnce() }

    @discardableResult
    func stopJobsTimer() -> Self { stopTimer() }

    @discardableResult
    func startJobsCountdown(total: Int,
                            interval: TimeInterval = 1.0,
                            kind: JobsTimerKind = .gcd) -> Self {
        startTimer(total: total, interval: interval, kind: kind)
    }

    @discardableResult
    func stopJobsCountdown(triggerFinish: Bool = false) -> Self {
        if triggerFinish {
            if let k = objc_getAssociatedObject(self, &_timerKindKey) as? JobsTimerKind,
               let fin = objc_getAssociatedObject(self, &_timerFinishAnyKey) as? (UIButton, JobsTimerKind) -> Void {
                fin(self, k)
            }
            if let legacyFin = objc_getAssociatedObject(self, &_legacyCountdownFinishKey) as? () -> Void {
                legacyFin()
            }
        };return stopTimer()
    }

    @discardableResult
    func onJobsCountdownTick(_ block: @escaping (_ remain: Int, _ total: Int) -> Void) -> Self {
        objc_setAssociatedObject(self,
                                 &_legacyCountdownTickKey,
                                 block,
            .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    @discardableResult
    func onJobsCountdownFinish(_ block: @escaping () -> Void) -> Self {
        objc_setAssociatedObject(self,
                                 &_legacyCountdownFinishKey,
                                 block,
            .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }
}
// MARK: 统一写回图片
public extension UIButton {
    @MainActor
    func jobsResetBtnImage(_ image: UIImage?, for state: UIControl.State) {
        if #available(iOS 15.0, *) {
            var cfg = self.configuration ?? .plain()  // ✅ 没有也创建；前景建议用 .plain()
            cfg.image = image                          // ✅ 前景图写到 configuration.image
            self.configuration = cfg
            byUpdateConfig()
        } else {
            self.setImage(image, for: state)          // ✅ 旧系统走 legacy API
        }
        if #available(iOS 15.0, *) {
            self.setNeedsUpdateConfiguration()
        }
    }
    @MainActor
    func jobsResetBtnBgImage(_ image: UIImage?, for state: UIControl.State) {
        // 先把最终图粘住，供后续任何 config 重建时回填
        self.jobs_cfgBgImage = image
        // ① legacy 背景图：立刻可见，最稳
        self.setBackgroundImage(image, for: state)
        // ② iOS 15+：把同一张图同步到 configuration.background，避免被下一次重建抹掉
        if #available(iOS 15.0, *) {
            var cfg = self.configuration ?? .plain()
            var bg  = cfg.background
            bg.image = image
            if bg.imageContentMode == .scaleToFill { bg.imageContentMode = .scaleAspectFill }
            bg.backgroundColor = .clear
            cfg.background = bg
            self.configuration = cfg

            // 让生命周期继续，但这里不要马上“强制”刷新，避免刚设的图被别的 handler 抢写
            self.automaticallyUpdatesConfiguration = true
            // self.setNeedsUpdateConfiguration()  // ← 刻意不在这里触发
        }
        // 保险刷新
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.setNeedsDisplay()
    }

    @available(iOS 15.0, *)
    private func _applySubtitleToConfigurationNow(targetState: UIControl.State = .normal) {
        // 1) 基于现有 configuration 开始，避免默认值把东西清空
        var cfg = self.configuration ?? .plain()
        // 2) 先把当前“有效背景图”抓出来，稍后再回填，防止被覆盖
        let currentBgImage: UIImage? = (
            cfg.background.image                               // 配置里已有背景
            ?? self.jobs_cfgBgImage                            // 我们粘住的背景
            ?? self.backgroundImage(for: targetState)          // legacy 背景（按 state）
            ?? self.backgroundImage(for: .normal)              // legacy 背景（normal）
        )
        // 3) 同步主标题（防 title 丢）
        if cfg.title == nil, let t = self.title(for: .normal), !t.isEmpty {
            cfg.title = t
        }
        cfg.titleAlignment = .center
        // 4) 应用副标题 + 字体/颜色
        let pack = self._subDict_noAttr[targetState.rawValue]
                ?? self._subDict_noAttr[UIControl.State.normal.rawValue]
        let text = pack?.text ?? ""
        cfg.subtitle = text.isEmpty ? nil : text

        let f = pack?.font
        let c = pack?.color
        cfg.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var a = incoming
            if let f { a.font = f }
            if let c { a.foregroundColor = c }
            return a
        }
        // 5) 关键：把背景图回填回去，并粘到 AO，防止后续 update 时丢失
        if let bgImg = currentBgImage {
            var bg = cfg.background
            bg.image = bgImg
            if bg.imageContentMode == .scaleToFill { bg.imageContentMode = .scaleAspectFill }
            bg.backgroundColor = .clear
            cfg.background = bg
            self.jobs_cfgBgImage = bgImg
        }
        // 6) 提交配置并触发更新（保持自动更新为开启）
        self.configuration = cfg
        self.automaticallyUpdatesConfiguration = true
        self.setNeedsUpdateConfiguration()
    }
}
// MARK: 获取@标题、副标题、前景图、背景图
public extension UIButton {
    /// 当前业务视角下的主标题：
    /// 优先 Configuration(.attributedTitle / .title)，再兜底 legacy title(for:)
    var title: String? {
        if #available(iOS 15.0, *), let cfg = self.configuration {
            if let att = cfg.attributedTitle {
                return String(att.characters)
            }
            if let t = cfg.title {
                return t
            }
        }
        let st = self.state
        return self.title(for: st)
            ?? self.attributedTitle(for: st)?.string
            ?? self.title(for: .normal)
            ?? self.attributedTitle(for: .normal)?.string
    }
    /// 当前业务视角下的副标题：
    /// 优先 Configuration(.attributedSubtitle / .subtitle)；
    /// iOS 15 以下只能从你之前组合的 “title\nsubtitle” 里拆。
    var subTitle: String? {
        if #available(iOS 15.0, *), let cfg = self.configuration {
            if let att = cfg.attributedSubtitle {
                return String(att.characters)
            }
            if let t = cfg.subtitle {
                return t
            }
        }
        // < iOS 15：你 bySubTitle 的旧实现是 title + "\n" + subTitle，这里尽量拆一下
        let st = self.state
        let full = self.title(for: st)
            ?? self.attributedTitle(for: st)?.string
            ?? self.title(for: .normal)
            ?? self.attributedTitle(for: .normal)?.string

        guard
            let full,
            let idx = full.firstIndex(of: "\n"),
            full.index(after: idx) < full.endIndex
        else {
            return nil
        }
        let sub = full[full.index(after: idx)...]
        return String(sub)
    }
    /// 当前前景图：优先 Configuration.image，再兜底 image(for:)
    var foregroundImage: UIImage? {
        if #available(iOS 15.0, *), let cfg = self.configuration, let img = cfg.image {
            return img
        }
        let st = self.state
        return self.image(for: st) ?? self.image(for: .normal)
    }
    /// 当前背景图：优先 Configuration.background.image，再兜底 backgroundImage(for:)
    /// （你前面 jobsResetBtnBgImage 已经保证两边是同步的）
    var backgroundImage: UIImage? {
        if #available(iOS 15.0, *), let cfg = self.configuration, let img = cfg.background.image {
            return img
        }
        let st = self.state
        return self.backgroundImage(for: st) ?? self.backgroundImage(for: .normal)
    }
}
// MARK: - SDWebImage
#if canImport(SDWebImage)
import UIKit
import SDWebImage
import ObjectiveC.runtime

public struct SDButtonLoadConfig {
    public var url: URL?
    public var placeholder: UIImage?
    public var options: SDWebImageOptions = []
    public var context: [SDWebImageContextOption: Any]? = nil
    public var progress: SDImageLoaderProgressBlock? = nil
    public var completed: SDExternalCompletionBlock? = nil

    public init() {}
}

private enum _SDButtonAOKey {
    static var config: UInt8 = 0
}

private extension UIButton {
    var _sd_config: SDButtonLoadConfig {
        get { (objc_getAssociatedObject(self, &_SDButtonAOKey.config) as? SDButtonLoadConfig) ?? SDButtonLoadConfig() }
        set { objc_setAssociatedObject(self, &_SDButtonAOKey.config, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

private extension UIButton {
    @discardableResult func _sd_setImageURL(_ url: URL?) -> Self { var c = _sd_config; c.url = url; _sd_config = c; return self }
    @discardableResult func _sd_setPlaceholder(_ img: UIImage?) -> Self { var c = _sd_config; c.placeholder = img; _sd_config = c; return self }
    @discardableResult func _sd_setOptions(_ opts: SDWebImageOptions) -> Self { var c = _sd_config; c.options = opts; _sd_config = c; return self }
    @discardableResult func _sd_setContext(_ ctx: [SDWebImageContextOption: Any]?) -> Self { var c = _sd_config; c.context = ctx; _sd_config = c; return self }
    @discardableResult func _sd_setProgress(_ block: SDImageLoaderProgressBlock?) -> Self { var c = _sd_config; c.progress = block; _sd_config = c; return self }
    @discardableResult func _sd_setCompleted(_ block: SDExternalCompletionBlock?) -> Self { var c = _sd_config; c.completed = block; _sd_config = c; return self }
}

public extension UIButton {
    @discardableResult func sd_imageURL(_ url: URL?) -> Self { _sd_setImageURL(url) }
    @discardableResult func sd_imageURL(_ urlString: String?) -> Self {
        guard let s = urlString, let u = URL(string: s) else { return _sd_setImageURL(nil) }
        return _sd_setImageURL(u)
    }
    @discardableResult func sd_placeholderImage(_ img: UIImage?) -> Self { _sd_setPlaceholder(img) }
    @discardableResult func sd_options(_ opts: SDWebImageOptions) -> Self { _sd_setOptions(opts) }
    @discardableResult func sd_context(_ ctx: [SDWebImageContextOption: Any]?) -> Self { _sd_setContext(ctx) }
    @discardableResult func sd_progress(_ block: SDImageLoaderProgressBlock?) -> Self { _sd_setProgress(block) }
    @discardableResult func sd_completed(_ block: SDExternalCompletionBlock?) -> Self { _sd_setCompleted(block) }

    @discardableResult func sd_normalLoad() -> Self { _sd_loadImage(for: .normal); return self }
    @discardableResult func sd_highlightedLoad() -> Self { _sd_loadImage(for: .highlighted); return self }
    @discardableResult func sd_disabledLoad() -> Self { _sd_loadImage(for: .disabled); return self }
    @discardableResult func sd_selectedLoad() -> Self { _sd_loadImage(for: .selected); return self }
    @available(iOS 9.0, *)
    @discardableResult func sd_focusedLoad() -> Self { _sd_loadImage(for: .focused); return self }
    @discardableResult func sd_applicationLoad() -> Self { _sd_loadImage(for: .application); return self }
    @discardableResult func sd_reservedLoad() -> Self { _sd_loadImage(for: .reserved); return self }

    @discardableResult func sd_bgNormalLoad() -> Self { _sd_loadBackgroundImage(for: .normal); return self }
    @discardableResult func sd_bgHighlightedLoad() -> Self { _sd_loadBackgroundImage(for: .highlighted); return self }
    @discardableResult func sd_bgDisabledLoad() -> Self { _sd_loadBackgroundImage(for: .disabled); return self }
    @discardableResult func sd_bgSelectedLoad() -> Self { _sd_loadBackgroundImage(for: .selected); return self }
    @available(iOS 9.0, *)
    @discardableResult func sd_bgFocusedLoad() -> Self { _sd_loadBackgroundImage(for: .focused); return self }
    @discardableResult func sd_bgApplicationLoad() -> Self { _sd_loadBackgroundImage(for: .application); return self }
    @discardableResult func sd_bgReservedLoad() -> Self { _sd_loadBackgroundImage(for: .reserved); return self }
}

public extension UIButton {
    func _sd_loadImage(for state: UIControl.State) {
        let cfg = _sd_config
        guard let url = cfg.url else {
            Task { @MainActor in self.jobsResetBtnImage(cfg.placeholder, for: state) }
            return
        }
        self.sd_setImage(with: url,
                         for: state,
                         placeholderImage: cfg.placeholder,
                         options: cfg.options,
                         context: cfg.context,
                         progress: cfg.progress) { [weak self] img, err, cacheType, imageURL in
            guard let self else { return }
            Task { @MainActor in
                self.jobsResetBtnImage(img ?? cfg.placeholder, for: state)
                cfg.completed?(img, err, cacheType, imageURL)
            }
        }
    }
    // ✅ SDWebImage：背景图加载（完整替换此方法）
    func _sd_loadBackgroundImage(for state: UIControl.State) {
        let cfg = _sd_config
        // 记录元数据（克隆/复用要用）
        self.jobs_bgURL = cfg.url
        self.jobs_bgState = state
        // 先显示占位图（用 legacy API，避免与 configuration 竞态）
        if let ph = cfg.placeholder {
            Task { @MainActor in self.jobsResetBtnBgImage(ph, for: state) }
        }
        guard let url = cfg.url else { return }
        // 取消在途任务（同一 state）
        self.sd_cancelBackgroundImageLoad(for: state)
        // 只在回调里写图，避免 SD 自动写回导致的闪白/覆盖
        var opts = cfg.options
        opts.insert(.continueInBackground)
        opts.insert(.highPriority)
        opts.insert(.avoidAutoSetImage)

        var ctx = cfg.context ?? [:]
        if ctx[.imageScaleFactor] == nil { ctx[.imageScaleFactor] = UIScreen.main.scale }
        // ❌ SD 没有 .imageTransition 这个 context 键，千万不要写它
        self.sd_setBackgroundImage(
            with: url,
            for: state,
            placeholderImage: cfg.placeholder,
            options: opts,
            context: ctx,
            progress: cfg.progress
        ) { [weak self] img, err, cacheType, _ in
            guard let self = self else { return }
            Task { @MainActor in
                let finalImage = img ?? cfg.placeholder
                // 如果是新下载（非缓存），做一次淡入；缓存命中则直接显示更干净
                if cacheType == .none, let finalImage {
                    UIView.transition(with: self, duration: 0.22, options: .transitionCrossDissolve, animations: {
                        self.jobsResetBtnBgImage(finalImage, for: state)
                    }, completion: nil)
                } else {
                    self.jobsResetBtnBgImage(finalImage, for: state)
                }
                cfg.completed?(img, err, cacheType, url)
            }
        }
    }
    /// 克隆 SD 的“背景图”到目标按钮：优先现成位图/配置 → 缓存 → 可选走网
    // ✅ SDWebImage：克隆背景图（完整替换此方法）
    /// 从“源按钮”克隆背景图到 target：
    /// 1) 先用现成位图（configuration / legacy）；
    /// 2) 命中缓存则立即显示；
    /// 3) 否则在 allowNetworkIfMissing=true 时触网下载（用你已有的 _sd_loadBackgroundImage 做手动淡入）
    func sd_cloneBackground(to target: UIButton,
                            for state: UIControl.State = .normal,
                            allowNetworkIfMissing: Bool = false) {
        target.jobs_isClone = true
        target.jobs_bgState = state
        // 先 snapshot 一份配置，避免跨 actor 反复读 AO
        let snapCfg = self._sd_config
        // 有效 URL：优先用 _sd_loadBackgroundImage 记录的 jobs_bgURL，退回配置里的 url
        let effectiveURL = self.jobs_bgURL ?? snapCfg.url
        // ===== 情况 1：没有 URL，说明是纯本地背景图，直接复用现成位图后结束 =====
        if effectiveURL == nil {
            if #available(iOS 15.0, *), let cfgImg = self.configuration?.background.image {
                Task { @MainActor in
                    target.jobsResetBtnBgImage(cfgImg, for: state)
                };return
            }
            if let img = self.backgroundImage(for: state) {
                Task { @MainActor in
                    target.jobsResetBtnBgImage(img, for: state)
                };return
            }
            // 只有占位图的极端情况
            if let ph = snapCfg.placeholder {
                Task { @MainActor in
                    target.jobsResetBtnBgImage(ph, for: state)
                }
            };return
        }
        // ===== 情况 2：有 URL，说明是远程图；此时现成位图很可能只是占位，不能直接 return =====
        if let ph = snapCfg.placeholder {
            Task { @MainActor in
                target.jobsResetBtnBgImage(ph, for: state)
            }
        }
        let url = effectiveURL!
        target.jobs_bgURL = url
        // 先查缓存（同步），命中就直接用缓存图
        let key = SDWebImageManager.shared.cacheKey(for: url) ?? url.absoluteString
        if let cached = SDImageCache.shared.imageFromCache(forKey: key) {
            Task { @MainActor in
                target.jobsResetBtnBgImage(cached, for: state)
            };return
        }
        // 不允许走网，直接停在占位图
        guard allowNetworkIfMissing else { return }
        // 允许走网：复制源按钮的加载配置；克隆场景加 avoidAutoSetImage，避免闪烁
        var opts = snapCfg.options
        opts.insert(.continueInBackground)
        opts.insert(.highPriority)
        opts.insert(.avoidAutoSetImage)

        target._sd_setImageURL(url)
        target._sd_setPlaceholder(snapCfg.placeholder)
        target._sd_setOptions(opts)
        target._sd_setContext(snapCfg.context)
        target._sd_setProgress(snapCfg.progress)
        target._sd_setCompleted(snapCfg.completed)
        // 用你已有的淡入版本，真正发起 SD 的背景图加载
        target._sd_loadBackgroundImage(for: state)
    }
    /// 克隆“前景图”
    func sd_cloneImage(to target: UIButton, for state: UIControl.State = .normal) {
        guard let url = _sd_config.url else { return }
        target._sd_setImageURL(url)
        target._sd_setPlaceholder(self._sd_config.placeholder)
        target._sd_setOptions(self._sd_config.options)
        target._sd_setContext(self._sd_config.context)
        target._sd_setProgress(self._sd_config.progress)
        target._sd_setCompleted(self._sd_config.completed)
        target._sd_loadImage(for: state)
    }
}
#endif
// MARK: - Kingfisher
#if canImport(Kingfisher)
import UIKit
import Kingfisher
import ObjectiveC.runtime

public struct KFButtonLoadConfig {
    public var url: URL?
    public var placeholder: UIImage?
    public var options: KingfisherOptionsInfo = []
    public var progress: ((_ receivedSize: Int64, _ totalSize: Int64) -> Void)?
    public var completed: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?

    public init() {}
}
// 修正上面行的泛型标注（渲染器转义问题）
public typealias KFCompleted = (Result<RetrieveImageResult, KingfisherError>) -> Void
private enum _KFButtonAOKey { static var config: UInt8 = 0 }
private var kfBgURLKey: UInt8 = 0
public extension UIButton {
    var _kf_config: KFButtonLoadConfig {
        get { (objc_getAssociatedObject(self, &_KFButtonAOKey.config) as? KFButtonLoadConfig) ?? KFButtonLoadConfig() }
        set { objc_setAssociatedObject(self, &_KFButtonAOKey.config, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

private extension UIButton {
    @discardableResult func _kf_setImageURL(_ url: URL?) -> Self { var c = _kf_config; c.url = url; _kf_config = c; return self }
    @discardableResult func _kf_setPlaceholder(_ img: UIImage?) -> Self { var c = _kf_config; c.placeholder = img; _kf_config = c; return self }
    @discardableResult func _kf_setOptions(_ opts: KingfisherOptionsInfo) -> Self { var c = _kf_config; c.options = opts; _kf_config = c; return self }
    @discardableResult func _kf_setProgress(_ block: ((_ receivedSize: Int64, _ totalSize: Int64) -> Void)?) -> Self { var c = _kf_config; c.progress = block; _kf_config = c; return self }
    @discardableResult func _kf_setCompleted(_ block: KFCompleted?) -> Self { var c = _kf_config; c.completed = block; _kf_config = c; return self }
}

public extension UIButton {
    // MARK: - 基础配置
    @discardableResult func kf_imageURL(_ url: URL?) -> Self { _kf_setImageURL(url) }
    @discardableResult func kf_imageURL(_ urlString: String?) -> Self {
        guard let s = urlString, let u = URL(string: s) else { return _kf_setImageURL(nil) }
        return _kf_setImageURL(u)
    }
    @discardableResult func kf_placeholderImage(_ img: UIImage?) -> Self { _kf_setPlaceholder(img) }
    @discardableResult func kf_options(_ opts: KingfisherOptionsInfo) -> Self { _kf_setOptions(opts) }
    @discardableResult func kf_progress(_ block: ((_ receivedSize: Int64, _ totalSize: Int64) -> Void)?) -> Self { _kf_setProgress(block) }
    @discardableResult func kf_completed(_ block: KFCompleted?) -> Self { _kf_setCompleted(block) }
    // MARK: - 前景图加载
    @discardableResult func kf_normalLoad() -> Self {
        _kf_loadImage(for: .normal)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() } // ✅刷新配置
        return self
    }
    @discardableResult func kf_highlightedLoad() -> Self {
        _kf_loadImage(for: .highlighted)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
        return self
    }
    @discardableResult func kf_disabledLoad() -> Self {
        _kf_loadImage(for: .disabled)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
        return self
    }
    @discardableResult func kf_selectedLoad() -> Self {
        _kf_loadImage(for: .selected)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
        return self
    }
    @available(iOS 9.0, *)
    @discardableResult func kf_focusedLoad() -> Self {
        _kf_loadImage(for: .focused)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
        return self
    }
    @discardableResult func kf_applicationLoad() -> Self {
        _kf_loadImage(for: .application)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
        return self
    }
    @discardableResult func kf_reservedLoad() -> Self {
        _kf_loadImage(for: .reserved)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
        return self
    }
    // MARK: - 背景图加载
    @discardableResult func kf_bgNormalLoad() -> Self {
        _kf_loadBackgroundImage(for: .normal)
        return self
    }
    @discardableResult func kf_bgHighlightedLoad() -> Self {
        _kf_loadBackgroundImage(for: .highlighted)
        return self
    }
    @discardableResult func kf_bgDisabledLoad() -> Self {
        _kf_loadBackgroundImage(for: .disabled)
        return self
    }
    @discardableResult func kf_bgSelectedLoad() -> Self {
        _kf_loadBackgroundImage(for: .selected)
        return self
    }
    @available(iOS 9.0, *)
    @discardableResult func kf_bgFocusedLoad() -> Self {
        _kf_loadBackgroundImage(for: .focused)
        return self
    }
    @discardableResult func kf_bgApplicationLoad() -> Self {
        _kf_loadBackgroundImage(for: .application)
        return self
    }
    @discardableResult func kf_bgReservedLoad() -> Self {
        _kf_loadBackgroundImage(for: .reserved)
        return self
    }
}

public extension UIButton {
    func _kf_loadImage(for state: UIControl.State) {
        let cfg = _kf_config
        guard let url = cfg.url else {
            Task { @MainActor in self.jobsResetBtnImage(cfg.placeholder, for: state) }
            return
        }
        self.kf.setImage(with: url,
                         for: state,
                         placeholder: cfg.placeholder,
                         options: cfg.options,
                         progressBlock: { r, t in cfg.progress?(Int64(r), Int64(t)) }) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let r): self.jobsResetBtnImage(r.image, for: state)
                case .failure:        self.jobsResetBtnImage(cfg.placeholder, for: state)
                }
                cfg.completed?(result)
            }
        }
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
    }
    // ✅ 2) Kingfisher 背景图加载：按原逻辑下载，回写时只走 jobsResetBtnBgImage（= legacy）
    func _kf_loadBackgroundImage(for state: UIControl.State) {
        let cfg = _kf_config
        self.jobs_bgURL = cfg.url
        self.jobs_bgState = state

        // 先立即显示占位
        if let ph = cfg.placeholder {
            Task { @MainActor in self.jobsResetBtnBgImage(ph, for: state) }
        }

        guard let url = cfg.url else { return }

        var opts = cfg.options
        if cfg.placeholder != nil {
            opts.removeAll { if case .keepCurrentImageWhileLoading = $0 { return true } else { return false } }
        } else if !opts.contains(where: { if case .keepCurrentImageWhileLoading = $0 { return true } else { return false } }) {
            opts.append(.keepCurrentImageWhileLoading)
        }
        if !opts.contains(where: { if case .backgroundDecode = $0 { return true } else { return false } }) {
            opts.append(.backgroundDecode)
        }

        // 用按钮绑定的 API，完成后只写 legacy 背景图（避免与 configuration 产生竞态）
        self.kf.setBackgroundImage(
            with: url,
            for: state,
            placeholder: cfg.placeholder,
            options: opts,
            progressBlock: { r, t in cfg.progress?(Int64(r), Int64(t)) }
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let s):
                    self.jobsResetBtnBgImage(s.image, for: state)
                case .failure:
                    self.jobsResetBtnBgImage(cfg.placeholder, for: state)
                }
                cfg.completed?(result)
            }
        }
    }
}

public extension UIButton {
    /// 记录用于背景图的 URL（供克隆阶段读取）
    var kf_bgURL: URL? {
        get { objc_getAssociatedObject(self, &kfBgURLKey) as? URL }
        set { objc_setAssociatedObject(self, &kfBgURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// 源按钮使用：设置背景图并记录 URL（建议在 Demo 中用它替换直接的 kf.setBackgroundImage）
    @discardableResult
    func kf_setBackgroundImageURL(_ urlString: String,
                                         for state: UIControl.State = .normal,
                                         placeholder: UIImage? = nil,
                                         options: KingfisherOptionsInfo = [.transition(.fade(0.2)), .cacheOriginalImage]) -> Self {
        guard let u = URL(string: urlString) else { return self }
        kf_bgURL = u
        self.kf.setBackgroundImage(with: u, for: state, placeholder: placeholder, options: options)
        return self
    }
    /// 克隆阶段调用：优先现成位图 → 缓存 →（按需）拉网
    // MARK: - 克隆：背景图（Kingfisher）— 可直接替换
    func kf_cloneBackground(to target: UIButton,
                            for state: UIControl.State = .normal,
                            allowNetworkIfMissing: Bool) {
        target.jobs_isClone = true
        target.jobs_bgState = state
        // 0) 配置先 snapshot 出来，后面到处要用
        let snapCfg = self._kf_config   // KFButtonLoadConfig
        // 1) 只有“纯本地背景图”（没有 url）时，才直接复用现成位图，不走缓存/网络
        if snapCfg.url == nil {
            if #available(iOS 15.0, *), let img = self.configuration?.background.image {
                Task { @MainActor in
                    target.jobsResetBtnBgImage(img, for: state)
                };return
            }
            if let img = self.backgroundImage(for: state) {
                Task { @MainActor in
                    target.jobsResetBtnBgImage(img, for: state)
                };return
            }
        }
        // 2) 先把占位图顶上，保证克隆按钮立刻有图
        let ph = snapCfg.placeholder
        if let ph {
            Task { @MainActor in
                target.jobsResetBtnBgImage(ph, for: state)
            }
        }
        // 3) URL：优先显式记录的 kf_bgURL，其次配置里的 url
        guard let url = self.kf_bgURL ?? snapCfg.url else { return }
        target.jobs_bgURL = url
        // 4) 只从缓存取一次（不会触网）
        var cacheOnlyOpts = snapCfg.options
        cacheOnlyOpts.append(.onlyFromCache)
        KingfisherManager.shared.retrieveImage(with: url, options: cacheOnlyOpts) { result in
            switch result {
            case .success(let r):
                // ✅ 命中缓存
                Task { @MainActor in
                    target.jobsResetBtnBgImage(r.image, for: state)
                }
            case .failure:
                // 5) 缓存没命中：按需走网
                guard allowNetworkIfMissing else { return }

                var opts = snapCfg.options
                // 克隆态建议去掉过渡动画，避免滚动闪一下
                opts.removeAll { if case .transition = $0 { return true } else { return false } }
                // 没占位时才保留 keepCurrentImageWhileLoading
                if ph == nil && !opts.contains(where: { if case .keepCurrentImageWhileLoading = $0 { return true } else { return false } }) {
                    opts.append(.keepCurrentImageWhileLoading)
                }
                // 强制后台解码
                if !opts.contains(where: { if case .backgroundDecode = $0 { return true } else { return false } }) {
                    opts.append(.backgroundDecode)
                }
                Task { @MainActor in
                    target.kf.setBackgroundImage(
                        with: url,
                        for: state,
                        placeholder: ph,
                        options: opts,
                        progressBlock: { r, t in snapCfg.progress?(Int64(r), Int64(t)) }
                    ) { res in
                        Task { @MainActor in
                            switch res {
                            case .success(let s):
                                target.jobsResetBtnBgImage(s.image, for: state)
                            case .failure:
                                target.jobsResetBtnBgImage(ph, for: state)
                            }
                            snapCfg.completed?(res)
                        }
                    }
                }
            }
        }
    }
    /// 克隆“前景图”
    func kf_cloneImage(to target: UIButton, for state: UIControl.State = .normal) {
        guard let url = _kf_config.url else { return }
        target._kf_setImageURL(url)
        target._kf_setPlaceholder(self._kf_config.placeholder)
        var o = self._kf_config.options
        if !o.contains(where: { if case .keepCurrentImageWhileLoading = $0 { return true } else { return false } }) {
            o.append(.keepCurrentImageWhileLoading)
        }
        target._kf_setOptions(o)
        target._kf_setProgress(self._kf_config.progress)
        target._kf_setCompleted(self._kf_config.completed)
        target._kf_loadImage(for: state)
    }
}
#endif

import AVFoundation
// =============== 全局默认值（保持不变） ===============
public enum JobsSound {
    public struct Defaults {
        public var bundle: Bundle = .main
        public var ignoreSilentSwitch = false   // 遵从静音键
        public var mixWithOthers = true         // 允许与其它 App 混音
        public init() {}
    }
    public static var defaults = Defaults()
}
// =============== 内部存储 ===============
private final class _JobsSoundBox: NSObject {
    let url: URL
    let ignoreSilentSwitch: Bool
    let mixWithOthers: Bool
    init(url: URL, ignoreSilentSwitch: Bool, mixWithOthers: Bool) {
        self.url = url
        self.ignoreSilentSwitch = ignoreSilentSwitch
        self.mixWithOthers = mixWithOthers
    }
}

private var _kTapSoundBoxKey: UInt8 = 0
private var _kTapSoundPlayerKey: UInt8 = 0
private var _kTapSoundActionIDKey: UInt8 = 0   // 仅 iOS14+ 用于 removeAction
private var _kTapSoundActionKey: UInt8 = 0
public extension UIButton {
    @discardableResult
    func byTapSound(_ nameWithExt: String) -> Self {
        // 查找资源
        let ns = nameWithExt as NSString
        let ext = ns.pathExtension
        let base = ns.deletingPathExtension
        guard !base.isEmpty,
              let url = JobsSound.defaults.bundle.url(forResource: base,
                                                      withExtension: ext.isEmpty ? nil : ext)
        else {
            // 找不到：解绑并静默
            _jobs_unbindTapHandler()
            objc_setAssociatedObject(self, &_kTapSoundBoxKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(self, &_kTapSoundPlayerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return self
        }
        // 固化当前默认配置
        let box = _JobsSoundBox(url: url,
                                ignoreSilentSwitch: JobsSound.defaults.ignoreSilentSwitch,
                                mixWithOthers: JobsSound.defaults.mixWithOthers)
        objc_setAssociatedObject(self, &_kTapSoundBoxKey, box, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        // 绑定点击：iOS14+ 用 UIAction(闭包)，老系统回退到 target-action
        _jobs_bindTapHandler()
        return self
    }

    @discardableResult
    func byRemoveTapSound() -> Self {
        _jobs_unbindTapHandler()
        objc_setAssociatedObject(self, &_kTapSoundBoxKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &_kTapSoundPlayerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    // MARK: - 点击时播放（核心逻辑）
    @objc private func _jobs_onTapPlaySound() {
        guard let box = objc_getAssociatedObject(self, &_kTapSoundBoxKey) as? _JobsSoundBox else { return }

        let session = AVAudioSession.sharedInstance()
        let category: AVAudioSession.Category = box.ignoreSilentSwitch ? .playback : .ambient
        var options: AVAudioSession.CategoryOptions = []
        if box.mixWithOthers { options.insert(.mixWithOthers) }
        try? session.setCategory(category, mode: .default, options: options)
        try? session.setActive(true, options: [])

        var player = objc_getAssociatedObject(self, &_kTapSoundPlayerKey) as? AVAudioPlayer
        if player == nil {
            player = try? AVAudioPlayer(contentsOf: box.url)
            player?.numberOfLoops = 0
            player?.prepareToPlay()
            objc_setAssociatedObject(self, &_kTapSoundPlayerKey, player, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        guard let p = player else { return }
        if p.isPlaying {
            p.stop()
            p.currentTime = 0
        }
        p.play()
    }

    private func _jobs_bindTapHandler() {
        if #available(iOS 14.0, *) {
            // 先移除旧 UIAction
            if let old = objc_getAssociatedObject(self, &_kTapSoundActionKey) as? UIAction {
                removeAction(old, for: .touchUpInside)
            }
            // 新建并保存 UIAction（闭包回调）
            let action = UIAction { [weak self] _ in
                self?._jobs_onTapPlaySound()
            }
            addAction(action, for: .touchUpInside)
            objc_setAssociatedObject(self, &_kTapSoundActionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            // 回退：target-action
            removeTarget(self, action: #selector(_jobs_onTapPlaySound), for: .touchUpInside)
            addTarget(self, action: #selector(_jobs_onTapPlaySound), for: .touchUpInside)
        }
    }

    private func _jobs_unbindTapHandler() {
        if #available(iOS 14.0, *) {
            if let old = objc_getAssociatedObject(self, &_kTapSoundActionKey) as? UIAction {
                removeAction(old, for: .touchUpInside)   // ✅ 正确的移除方式
                objc_setAssociatedObject(self, &_kTapSoundActionKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        } else {
            removeTarget(self, action: #selector(_jobs_onTapPlaySound), for: .touchUpInside)
        }
    }
}
// MARK: 按钮背景图加载（UIImage / Base64 / URL）
public enum JobsImageSource: Equatable {
    case image(UIImage)
    case base64(String)      // 纯 Base64（不含 "data:" 前缀）
    case url(URL)            // 远端 URL
}

private final class _JobsImageCache {
    static let shared = _JobsImageCache()
    let cache = NSCache<NSString, UIImage>()
    private init() {}
}

public extension UIButton {
    @discardableResult
    func byBackgroundImage(_ source: JobsImageSource?, for state: UIControl.State = .normal) -> Self {
        guard let source else {
            self.setBackgroundImage(nil, for: state)
            return self
        }
        switch source {
        case .image(let img):
            self.setBackgroundImage(img, for: state)

        case .base64(let b64):
            if let data = Data(base64Encoded: b64, options: .ignoreUnknownCharacters),
               let img = UIImage(data: data) {
                self.setBackgroundImage(img, for: state)
            } else {
                self.setBackgroundImage(nil, for: state)
            }

        case .url(let url):
            let key = url.absoluteString as NSString
            if let cached = _JobsImageCache.shared.cache.object(forKey: key) {
                self.setBackgroundImage(cached, for: state)
            } else {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let self, let data, let img = UIImage(data: data) else { return }
                    _JobsImageCache.shared.cache.setObject(img, forKey: key)
                    DispatchQueue.main.async {
                        self.setBackgroundImage(img, for: state)
                    }
                }.resume()
            }
        };return self
    }
}
#if canImport(SnapKit)
// MARK: 为空态按钮附加自定义布局闭包
import SnapKit
public var _jobsEmptyLayoutKey: UInt8 = 0
public extension UIButton {
    typealias JobsEmptyLayout = (_ btn: UIButton, _ make: ConstraintMaker, _ host: UIScrollView) -> Void
    /// 内部读取：UIScrollView._jobs_attachEmptyButton 会使用
    var _jobsEmptyLayout: JobsEmptyLayout? {
        get { objc_getAssociatedObject(self, &_jobsEmptyLayoutKey) as? JobsEmptyLayout }
        set { objc_setAssociatedObject(self, &_jobsEmptyLayoutKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    /// 链式：设置空态按钮的自定义布局
    @discardableResult
    func jobs_setEmptyLayout(_ layout: @escaping JobsEmptyLayout) -> Self {
        self._jobsEmptyLayout = layout
        return self
    }
}
#endif
