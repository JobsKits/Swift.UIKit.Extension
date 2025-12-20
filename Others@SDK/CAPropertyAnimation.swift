//
//  CAPropertyAnimation.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/9/25.
//

import QuartzCore

public extension CAPropertyAnimation {
    /// keyPath
    @discardableResult
    func byKeyPath(_ path: String?) -> Self {
        self.keyPath = path
        return self
    }
    /// additive
    @discardableResult
    func byAdditive(_ flag: Bool) -> Self {
        self.isAdditive = flag
        return self
    }
    /// cumulative
    @discardableResult
    func byCumulative(_ flag: Bool) -> Self {
        self.isCumulative = flag
        return self
    }
    /// valueFunction
    @discardableResult
    func byValueFunction(_ fn: CAValueFunction?) -> Self {
        self.valueFunction = fn
        return self
    }
}
