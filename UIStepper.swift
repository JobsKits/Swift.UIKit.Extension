//
//  UIStepper.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

extension UIStepper {
    @discardableResult
    func byValue(_ value: Double) -> Self {
        self.value = value
        return self
    }

    @discardableResult
    func byMinimumValue(_ min: Double) -> Self {
        self.minimumValue = min
        return self
    }

    @discardableResult
    func byMaximumValue(_ max: Double) -> Self {
        self.maximumValue = max
        return self
    }

    @discardableResult
    func byStepValue(_ step: Double) -> Self {
        self.stepValue = step
        return self
    }

    @discardableResult
    func byContinuous(_ continuous: Bool) -> Self {
        self.isContinuous = continuous
        return self
    }

    @discardableResult
    func byAutorepeat(_ autorepeat: Bool) -> Self {
        self.autorepeat = autorepeat
        return self
    }

    @discardableResult
    func byWraps(_ wraps: Bool) -> Self {
        self.wraps = wraps
        return self
    }
}
