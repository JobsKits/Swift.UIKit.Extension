//
//  UIButton+DSL.swift
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
            };return button
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
            contentEdgeInsets = UIEdgeInsets(top: insets.top,
                                             left: insets.leading,
                                             bottom: insets.bottom,
                                             right: insets.trailing)
        };return self
    }

    @discardableResult
    func byContentEdgeInsets(_ insets: UIEdgeInsets) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .filled()
            cfg.contentInsets = NSDirectionalEdgeInsets(top: insets.top,
                                                        leading: insets.left,
                                                        bottom: insets.bottom,
                                                        trailing: insets.right)
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
            cfg.contentInsets = NSDirectionalEdgeInsets(top: insets.top,
                                                        leading: insets.left,
                                                        bottom: insets.bottom,
                                                        trailing: insets.right)
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
                contentEdgeInsets = UIEdgeInsets(top: inset,
                                                 left: inset,
                                                 bottom: inset,
                                                 right: inset)
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
// MARK: - 交互 / 菜单 / 角色 / Pointer / Config 生命周期
public extension UIButton {
    @available(iOS 14.0, *)
    @discardableResult
    func byMenu(_ menu: UIMenu?) -> Self {
        self.menu = menu;
        return self
    }

    @available(iOS 13.4, *)
    @discardableResult
    func byPointerInteractionEnabled(_ on: Bool) -> Self {
        self.isPointerInteractionEnabled = on;
        return self
    }

    @available(iOS 14.0, *)
    @discardableResult
    func byRole(_ role: UIButton.Role) -> Self {
        self.role = role;
        return self
    }

    @available(iOS 16.0, *)
    @discardableResult
    func byPreferredMenuElementOrder(_ order: UIContextMenuConfiguration.ElementOrder) -> Self {
        self.preferredMenuElementOrder = order; return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func byChangesSelectionAsPrimaryAction(_ on: Bool) -> Self {
        self.changesSelectionAsPrimaryAction = on;
        return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func byAutomaticallyUpdatesConfiguration(_ on: Bool) -> Self {
        self.automaticallyUpdatesConfiguration = on;
        return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func byConfigurationUpdateHandler(_ handler: @escaping UIButton.ConfigurationUpdateHandler) -> Self {
        self.configurationUpdateHandler = handler;
        return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func bySetNeedsUpdateConfiguration() -> Self {
        self.setNeedsUpdateConfiguration();
        return self
    }
}
