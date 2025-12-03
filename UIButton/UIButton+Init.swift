//
//  UIButton+Init.swift
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
// MARK: - init
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
