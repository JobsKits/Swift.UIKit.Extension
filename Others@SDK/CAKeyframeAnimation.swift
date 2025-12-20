//
//  CAKeyframeAnimation.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/9/25.
//

import QuartzCore
import CoreGraphics

public extension CAKeyframeAnimation {
    /// values
    @discardableResult
    func byValues(_ values: [Any]?) -> Self {
        self.values = values
        return self
    }
    /// path（用 CGPath）
    @discardableResult
    func byPath(_ path: CGPath?) -> Self {
        self.path = path
        return self
    }
    /// keyTimes
    @discardableResult
    func byKeyTimes(_ keyTimes: [NSNumber]?) -> Self {
        self.keyTimes = keyTimes
        return self
    }
    /// timingFunctions（逐段 timing）
    @discardableResult
    func byTimingFunctions(_ functions: [CAMediaTimingFunction]?) -> Self {
        self.timingFunctions = functions
        return self
    }
    /// calculationMode
    @discardableResult
    func byCalculationMode(_ mode: CAAnimationCalculationMode) -> Self {
        self.calculationMode = mode
        return self
    }
    /// tensionValues
    @discardableResult
    func byTensionValues(_ values: [NSNumber]?) -> Self {
        self.tensionValues = values
        return self
    }
    /// continuityValues
    @discardableResult
    func byContinuityValues(_ values: [NSNumber]?) -> Self {
        self.continuityValues = values
        return self
    }
    /// biasValues
    @discardableResult
    func byBiasValues(_ values: [NSNumber]?) -> Self {
        self.biasValues = values
        return self
    }
    /// rotationMode
    @discardableResult
    func byRotationMode(_ mode: CAAnimationRotationMode?) -> Self {
        self.rotationMode = mode
        return self
    }
    #if canImport(UIKit)
    /// 方便直接传 UIBezierPath
    @discardableResult
    func byPath(_ bezierPath: UIBezierPath?) -> Self {
        self.path = bezierPath?.cgPath
        return self
    }
    #endif
}
