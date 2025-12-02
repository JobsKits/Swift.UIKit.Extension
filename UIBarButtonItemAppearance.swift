//
//  UIBarButtonItemAppearance.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/2/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

@available(iOS 13.0, *)
public extension UIBarButtonItemAppearance {
    /// 快速配置不同状态的文本与颜色
    @discardableResult
    func byTitleColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        switch state {
        case .normal:
            self.normal.titleTextAttributes[.foregroundColor] = color
        case .highlighted:
            self.highlighted.titleTextAttributes[.foregroundColor] = color
        case .disabled:
            self.disabled.titleTextAttributes[.foregroundColor] = color
        case .focused:
            self.focused.titleTextAttributes[.foregroundColor] = color
        default:
            self.normal.titleTextAttributes[.foregroundColor] = color
        };return self
    }

    @discardableResult
    func byFont(_ font: UIFont, for state: UIControl.State = .normal) -> Self {
        switch state {
        case .normal:
            self.normal.titleTextAttributes[.font] = font
        case .highlighted:
            self.highlighted.titleTextAttributes[.font] = font
        case .disabled:
            self.disabled.titleTextAttributes[.font] = font
        case .focused:
            self.focused.titleTextAttributes[.font] = font
        default:
            self.normal.titleTextAttributes[.font] = font
        };return self
    }
}
