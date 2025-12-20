//
//  UIWindowScene.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/4/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

@available(iOS 13.0, *)
public extension UIWindowScene {
    var keyWindowCompat: UIWindow? {
        if #available(iOS 15.0, *) {
            return self.keyWindow
        } else {
            return self.windows.first(where: { $0.isKeyWindow })
        }
    }
}

@available(*, deprecated, message: "Use UIWindowScene.keyWindow instead on iOS 13+")
public func legacyKeyWindowPreiOS13() -> UIWindow? {
    return UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first
}
