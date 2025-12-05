//
//  UITextView.swift
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

import RxSwift
import RxCocoa
import RxRelay

public enum JobsTVKeys {
    static var onChangeBag: UInt8 = 0
    static var linkTapProxy: UInt8 = 0
    static var backspaceBag: UInt8 = 0
}

public enum TwoWayInitial {
    case fromRelay   // 默认：用 relay 覆盖 view
    case fromView    // 用 view 的当前值覆盖 relay
}
// MARK: 🧱 组件模型（UITextView 版）
public struct RxTextViewInput {
    public let text: Observable<String?>
    public let textOrEmpty: Observable<String>
    public let trimmed: Observable<String>

    public let isEditing: Observable<Bool>
    public let didPressDelete: Observable<Void>
    public let didChange: ControlEvent<Void> // 文本变化事件

    public let isValid: Observable<Bool>
    public let formattedBinder: Binder<String>
}

public var kProxyKey: UInt8 = 0
public var kTapKey:  UInt8 = 0

public extension UITextView {
    static let didPressTextViewDeleteNotification = Notification.Name("UITextView.didPressDelete")
}
