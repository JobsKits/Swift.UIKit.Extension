//
//  UIButton+富文本.swift
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
