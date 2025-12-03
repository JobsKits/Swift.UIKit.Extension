//
//  UIButton+Subtitle.swift
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

private extension UIControl.State { var raw: UInt { rawValue } }
// MARK: - Subtitle（无富文本）
public struct _JobsSubPackNoAttr {
    var text: String = ""
    var font: UIFont?
    var color: UIColor?
}
public var _jobsSubDictKey_noAttr: UInt8 = 0
public var _jobsSubtitleHandlerInstalledKey: UInt8 = 0
public var _jobsCfgBgImageKey: UInt8 = 0
public extension UIButton {
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
