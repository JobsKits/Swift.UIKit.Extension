//
//  UIButton+Configuration.swift
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
