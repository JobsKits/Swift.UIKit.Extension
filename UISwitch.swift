//
//  UISwitch.swift
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

extension UISwitch {
    @discardableResult
    func byOn(_ on: Bool) -> Self {
        self.setOn(on, animated: false)
        return self
    }
    
    @discardableResult
    func byOnAnimated(_ on: Bool) -> Self {
        self.setOn(on, animated: true)
        return self
    }
    
    @discardableResult
    func byOnTintColor(_ color: UIColor) -> Self {
        self.onTintColor = color
        return self
    }

    @discardableResult
    func byThumbTintColor(_ color: UIColor) -> Self {
        self.thumbTintColor = color
        return self
    }
}
