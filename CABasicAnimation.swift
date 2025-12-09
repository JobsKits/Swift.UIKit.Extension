//
//  CABasicAnimation.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/9/25.
//

import QuartzCore

public extension CABasicAnimation {
    /// fromValue
    @discardableResult
    func byFromValue(_ value: Any?) -> Self {
        self.fromValue = value
        return self
    }
    /// toValue
    @discardableResult
    func byToValue(_ value: Any?) -> Self {
        self.toValue = value
        return self
    }
    /// byValue
    @discardableResult
    func byByValue(_ value: Any?) -> Self {
        self.byValue = value
        return self
    }
}
