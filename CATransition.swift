//
//  CATransition.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/9/25.
//

import QuartzCore

public extension CATransition {
    /// 统一入口：CATransition.make { $0.byType(...).bySubtype(...) }
    static func make(_ configure: jobsByCATransitionBlock) -> CATransition {
        let t = CATransition()
        configure(t)
        return t
    }
}

public extension CATransition {

    @discardableResult
    func byType(_ type: CATransitionType) -> Self {
        self.type = type
        return self
    }

    @discardableResult
    func bySubtype(_ subtype: CATransitionSubtype?) -> Self {
        self.subtype = subtype
        return self
    }

    @discardableResult
    func byStartProgress(_ value: Float) -> Self {
        self.startProgress = value
        return self
    }

    @discardableResult
    func byEndProgress(_ value: Float) -> Self {
        self.endProgress = value
        return self
    }

    #if targetEnvironment(macCatalyst)
    @available(macCatalyst 13.1, *)
    @discardableResult
    func byCIFilter(_ filter: CIFilter?) -> Self {
        self.filter = filter
        return self
    }
    #endif
}
