//
//  UIView+确认和取消@回调.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

private struct JobsConfirmKeys {
    static var confirm: UInt8 = 0
    static var cancel:  UInt8 = 0
}

public extension UIView {
    var confirmHandler: jobsByVoidBlock? {
        get {
            objc_getAssociatedObject(self, &JobsConfirmKeys.confirm) as? jobsByVoidBlock
        }
        set {
            objc_setAssociatedObject(self,
                                     &JobsConfirmKeys.confirm,
                                     newValue,
                                     .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    var cancelHandler: jobsByVoidBlock? {
        get {
            objc_getAssociatedObject(self, &JobsConfirmKeys.cancel) as? jobsByVoidBlock
        }
        set {
            objc_setAssociatedObject(self,
                                     &JobsConfirmKeys.cancel,
                                     newValue,
                                     .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    /// 确认回调
    @discardableResult
    func onConfirm(_ handler: @escaping jobsByVoidBlock) -> Self {
        confirmHandler = handler
        return self
    }
    /// 取消回调
    @discardableResult
    func onCancel(_ handler: @escaping jobsByVoidBlock) -> Self {
        cancelHandler = handler
        return self
    }

    func jobs_fireConfirm() {
        confirmHandler?()
    }

    func jobs_fireCancel() {
        cancelHandler?()
    }
}
