//
//  UITabBarController.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

extension UITabBarController {
    @discardableResult
    func byViewControllersByAnimated(_ controllers: [UIViewController]) -> Self {
        self.setViewControllers(controllers, animated: true)
        return self
    }
    
    @discardableResult
    func byViewControllers(_ controllers: [UIViewController]) -> Self {
        self.setViewControllers(controllers, animated: false)
        return self
    }

    @discardableResult
    func bySelectedIndex(_ index: Int) -> Self {
        self.selectedIndex = index
        return self
    }

    @discardableResult
    func byDelegate(_ delegate: UITabBarControllerDelegate?) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult
    func byTabBarTintColor(_ color: UIColor) -> Self {
        self.tabBar.tintColor = color
        return self
    }

    @discardableResult
    func byTabBarBackgroundColor(_ color: UIColor) -> Self {
        self.tabBar.barTintColor = color
        return self
    }
}
