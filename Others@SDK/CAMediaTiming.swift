//
//  CAMediaTiming.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/9/25.
//

import QuartzCore

public extension CAMediaTiming where Self: AnyObject {
    // beginTime
    @discardableResult
    func byBeginTime(_ value: CFTimeInterval) -> Self {
        self.beginTime = value
        return self
    }
    // duration
    @discardableResult
    func byDuration(_ value: CFTimeInterval) -> Self {
        self.duration = value
        return self
    }
    // speed
    @discardableResult
    func bySpeed(_ value: Float) -> Self {
        self.speed = value
        return self
    }
    // timeOffset
    @discardableResult
    func byTimeOffset(_ value: CFTimeInterval) -> Self {
        self.timeOffset = value
        return self
    }
    // repeatCount
    @discardableResult
    func byRepeatCount(_ value: Float) -> Self {
        self.repeatCount = value
        return self
    }
    // repeatDuration
    @discardableResult
    func byRepeatDuration(_ value: CFTimeInterval) -> Self {
        self.repeatDuration = value
        return self
    }
    // autoreverses
    @discardableResult
    func byAutoreverses(_ flag: Bool) -> Self {
        self.autoreverses = flag
        return self
    }
    // fillMode
    @discardableResult
    func byFillMode(_ mode: CAMediaTimingFillMode) -> Self {
        self.fillMode = mode
        return self
    }
}
