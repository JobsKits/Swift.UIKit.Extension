//
//  NSObject+屏幕常亮.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/9/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
// MARK: - 屏幕常亮
public extension NSObject {
    /// 屏幕是否保持常亮
    var isScreenAlwaysOn: Bool {
        get { UIApplication.shared.isIdleTimerDisabled }
        set { UIApplication.shared.isIdleTimerDisabled = newValue }
    }
    /// 开启常亮
    func keepScreenOn() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    /// 关闭常亮
    func endScreenOn() {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
