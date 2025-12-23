//
//  UIButton+获取UI.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
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
// MARK: 获取@contentEdgeInsets、imageEdgeInsets（兼容Configuration）
public extension UIButton {
    /// ✅ 业务视角下的「内容内边距」：
    /// - iOS/tvOS 15+ 且使用 UIButton.Configuration 时：读取 cfg.contentInsets
    /// - 否则：读取 legacy contentEdgeInsets（⚠️ 该属性在 iOS15+ 已 deprecated，但仍可存取）
    var jobs_contentEdgeInsets: UIEdgeInsets {
        if #available(iOS 15.0, tvOS 15.0, *), let cfg = self.configuration {
            return jobs_uiEdgeInsets(from: cfg.contentInsets)
        }
        return jobs_legacyContentEdgeInsets
    }
    /// ✅ 业务视角下的「图片内边距」：
    /// - iOS/tvOS 15+ 且使用 UIButton.Configuration 时：legacy imageEdgeInsets 会被系统忽略
    ///   所以这里返回 .zero（并建议改用 cfg.imagePadding / cfg.imagePlacement）
    /// - 否则：读取 legacy imageEdgeInsets
    var jobs_imageEdgeInsets: UIEdgeInsets {
        if #available(iOS 15.0, tvOS 15.0, *), self.configuration != nil {
            return .zero
        }
        return jobs_legacyImageEdgeInsets
    }
    /// ✅ 读取 legacy contentEdgeInsets（避免直接引用 deprecated API 产生 warning）
    var jobs_legacyContentEdgeInsets: UIEdgeInsets {
        jobs_kvcEdgeInsets("contentEdgeInsets")
    }
    /// ✅ 读取 legacy imageEdgeInsets（避免直接引用 deprecated API 产生 warning）
    var jobs_legacyImageEdgeInsets: UIEdgeInsets {
        jobs_kvcEdgeInsets("imageEdgeInsets")
    }
    /// iOS/tvOS 15+：如果你想在 Configuration 模式下拿到“等价信息”，建议直接读这些字段
    @available(iOS 15.0, tvOS 15.0, *)
    var jobs_cfgContentInsets: NSDirectionalEdgeInsets? {
        self.configuration?.contentInsets
    }

    @available(iOS 15.0, tvOS 15.0, *)
    var jobs_cfgImagePadding: CGFloat? {
        self.configuration?.imagePadding
    }

    @available(iOS 15.0, tvOS 15.0, *)
    var jobs_cfgImagePlacement: NSDirectionalRectEdge? {
        self.configuration?.imagePlacement
    }
}

private extension UIButton {
    /// 用 KVC 读取 UIEdgeInsets，避免直接触达 iOS15+ deprecated 的属性导致编译 warning。
    /// - Note: 在使用 UIButton.Configuration 时，这些 legacy 值「可能存在但不会生效」。
    func jobs_kvcEdgeInsets(_ key: String) -> UIEdgeInsets {
        guard let v = self.value(forKey: key) as? NSValue else { return .zero }
        return v.uiEdgeInsetsValue
    }

    @available(iOS 15.0, tvOS 15.0, *)
    func jobs_uiEdgeInsets(from di: NSDirectionalEdgeInsets) -> UIEdgeInsets {
        // Directional -> UIEdgeInsets 需要考虑 RTL
        let isRTL = (self.effectiveUserInterfaceLayoutDirection == .rightToLeft)
        let left = isRTL ? di.trailing : di.leading
        let right = isRTL ? di.leading : di.trailing
        return UIEdgeInsets(top: di.top, left: left, bottom: di.bottom, right: right)
    }
}
