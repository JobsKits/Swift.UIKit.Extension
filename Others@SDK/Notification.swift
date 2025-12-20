//
//  Notification.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/26/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
/// 通知分类
extension Notification.Name {
    /// 用户登陆
    static let userDidLogin = Notification.Name("userDidLogin")
    /// 跳转在线客服通知
    static let pushOnlineCustomerService = Notification.Name("pushOnlineCustomerService")
}
