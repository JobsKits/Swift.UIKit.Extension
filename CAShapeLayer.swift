//
//  CAShapeLayer.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/28/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

extension CAShapeLayer {
    // MARK: - 基础属性
    @discardableResult
    func byPath(_ path: CGPath?) -> Self {
        self.path = path
        return self
    }
    // MARK: - 颜色（支持 UIColor / CGColor）
    @discardableResult
    func byFillColor(_ color: UIColor?) -> Self {
        self.fillColor = color?.cgColor
        return self
    }

    @discardableResult
    func byFillCGColor(_ color: CGColor?) -> Self {
        self.fillColor = color
        return self
    }

    @discardableResult
    func byStrokeColor(_ color: UIColor?) -> Self {
        self.strokeColor = color?.cgColor
        return self
    }

    @discardableResult
    func byStrokeCGColor(_ color: CGColor?) -> Self {
        self.strokeColor = color
        return self
    }
    // MARK: - 线条相关
    @discardableResult
    func byLineWidth(_ width: CGFloat) -> Self {
        self.lineWidth = width
        return self
    }

    @discardableResult
    func byStrokeStart(_ value: CGFloat) -> Self {
        self.strokeStart = value
        return self
    }

    @discardableResult
    func byStrokeEnd(_ value: CGFloat) -> Self {
        self.strokeEnd = value
        return self
    }

    @discardableResult
    func byMiterLimit(_ value: CGFloat) -> Self {
        self.miterLimit = value
        return self
    }

    @discardableResult
    func byLineDashPhase(_ phase: CGFloat) -> Self {
        self.lineDashPhase = phase
        return self
    }

    @discardableResult
    func byLineDashPattern(_ pattern: [NSNumber]?) -> Self {
        self.lineDashPattern = pattern
        return self
    }
    // MARK: - 线条样式（枚举）
    @discardableResult
    func byLineCap(_ cap: CAShapeLayerLineCap) -> Self {
        self.lineCap = cap
        return self
    }

    @discardableResult
    func byLineJoin(_ join: CAShapeLayerLineJoin) -> Self {
        self.lineJoin = join
        return self
    }

    @discardableResult
    func byFillRule(_ rule: CAShapeLayerFillRule) -> Self {
        self.fillRule = rule
        return self
    }
}
