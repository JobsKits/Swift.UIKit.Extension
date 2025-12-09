//
//  CAAnimation.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/9/25.
//

import QuartzCore

public extension CAAnimation {
    /// timingFunction
    @discardableResult
    func byTimingFunction(_ function: CAMediaTimingFunction?) -> Self {
        self.timingFunction = function
        return self
    }
    /// delegate
    @discardableResult
    func byDelegate(_ delegate: CAAnimationDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
    /// removedOnCompletion
    @discardableResult
    func byRemovedOnCompletion(_ flag: Bool) -> Self {
        self.isRemovedOnCompletion = flag
        return self
    }
    /// preferredFrameRateRange（跟系统可用性保持一致）
    @available(iOS 15.0,*)
    @discardableResult
    func byPreferredFrameRateRange(_ range: CAFrameRateRange) -> Self {
        self.preferredFrameRateRange = range
        return self
    }
}
