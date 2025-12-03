//
//  UIButton+获取UI.swift
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
