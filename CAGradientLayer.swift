//
//  CAGradientLayer.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
import ObjectiveC
// MARK: - Direction
public enum JobsGradientDirection {
    case leftToRight, rightToLeft, topToBottom, bottomToTop
    case tlToBr, brToTl, trToBl, blToTr
}
// MARK: - CAGradientLayer DSL
public extension CAGradientLayer {
    @discardableResult
    func byColors(_ uiColors: [UIColor]) -> Self {
        self.colors = uiColors.map { $0.cgColor }; return self
    }

    @discardableResult
    func byCGColors(_ cgColors: [CGColor]) -> Self {
        self.colors = cgColors; return self
    }

    @discardableResult
    func byLocations(_ locs: [CGFloat]) -> Self {
        self.locations = locs.map { NSNumber(value: Double($0)) }; return self
    }

    @discardableResult
    func byStartPoint(_ p: CGPoint) -> Self { self.startPoint = p; return self }

    @discardableResult
    func byEndPoint(_ p: CGPoint) -> Self { self.endPoint = p; return self }

    @discardableResult
    func byPoints(_ start: CGPoint, _ end: CGPoint) -> Self {
        self.startPoint = start; self.endPoint = end; return self
    }

    @discardableResult
    func byType(_ t: CAGradientLayerType) -> Self { self.type = t; return self }

    @discardableResult
    func byLayerFrame(_ f: CGRect) -> Self { self.frame = f; return self }
    /// 插入到某个 view 的 layer（默认最底层）
    @discardableResult
    func byInsert(into view: UIView, at index: UInt32 = 0) -> Self {
        view.layer.insertSublayer(self, at: index)
        CATransaction.begin(); CATransaction.setDisableActions(true)
        self.frame = view.bounds
        CATransaction.commit()
        return self
    }
    /// 快捷设置渐变方向
    @discardableResult
    func byDirection(_ d: JobsGradientDirection) -> Self {
        switch d {
        case .leftToRight:  startPoint = .init(x: 0, y: 0.5); endPoint = .init(x: 1, y: 0.5)
        case .rightToLeft:  startPoint = .init(x: 1, y: 0.5); endPoint = .init(x: 0, y: 0.5)
        case .topToBottom:  startPoint = .init(x: 0.5, y: 0); endPoint = .init(x: 0.5, y: 1)
        case .bottomToTop:  startPoint = .init(x: 0.5, y: 1); endPoint = .init(x: 0.5, y: 0)
        case .tlToBr:       startPoint = .init(x: 0, y: 0);   endPoint = .init(x: 1, y: 1)
        case .brToTl:       startPoint = .init(x: 1, y: 1);   endPoint = .init(x: 0, y: 0)
        case .trToBl:       startPoint = .init(x: 1, y: 0);   endPoint = .init(x: 0, y: 1)
        case .blToTr:       startPoint = .init(x: 0, y: 1);   endPoint = .init(x: 1, y: 0)
        }
        return self
    }
}
